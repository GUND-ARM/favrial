require 'open-uri'

# == Schema Information
#
# Table name: tweets
#
#  id                  :bigint           not null, primary key
#  t_id                :string
#  body                :text
#  url                 :string
#  raw_json            :text
#  media_type          :string
#  classification      :string
#  classified          :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  first_media_url     :string
#  user_id             :bigint
#  original_created_at :datetime
#
class Tweet < ApplicationRecord
  # こんなかんじで定数の一覧がとれる
  #
  # Tweet::Classification.constants.each do |k|
  #   p Tweet::Classification.const_get(k)
  # end
  #
  # スレミオ分類
  # FIXME: Concernにくくりだすのがいいかも？
  # FIXME: Solargraphが定数を拾ってこれないのでうまみがない. ベタ書きしたほうがいいかも
  module Classification
    [
      :SULETTA,  # スレッタ単体
      :MIORINE,  # ミオリネ単体
      :SULEMIO,  # スレミオ
      :OTHER,     # それ以外
      :NOTSULEMIO # スレミオではない
      #:WITHHOLD, # 判断を保留する（心がふたつあるんじゃ）
    ].each do |k|
      const_set(k, k.to_s.downcase.freeze)
    end

    def self.constants_hash
      constants.map do |k|
        [k, const_get(k)]
      end.to_h
    end
  end

  # 表現されているものの種類
  module ContentType
    module Photo
      [
        :ILLUSTRATION, # イラスト（マンガではない絵）
        :MANGA,        # マンガ
        :NOVEL,        # 画像化された小説
        :OTHER         # 本編キャプチャによる萌え語り, フィギュアやプラモの撮影など？
      ].each do |k|
        const_set(k, k.to_s.downcase.freeze)
      end
    end

    def self.constants_hash
      constants.map do |k|
        [k, const_get(k)]
      end.to_h
    end
  end

  # メディアタイプ（画像つきのツィートかどうか）
  module MediaType
    [
      :PHOTO,   # 画像つきツィート
      :NONE,    # メディアの無いツィート
      :OTHER    # その他のツィート
    ].each do |k|
      const_set(k, k.to_s.downcase.freeze)
    end

    def self.constants_hash
      constants.map do |k|
        [k, const_get(k)]
      end.to_h
    end
  end

  belongs_to :user, optional: true
  has_many :classify_results, dependent: :destroy
  has_many :sulemio_by_ml_classify_results,
           -> { where(by_ml: true, classification: Classification::SULEMIO, result: true) },
           class_name: 'ClassifyResult'
  has_many :by_user_classify_results,
           -> { where(by_ml: false) },
           class_name: 'ClassifyResult'

  validates :t_id, uniqueness: true, presence: true

  attribute :a_classification, :string # 元々あったclassificationのかわりに使う
  attribute :classified, default: false

  scope :unprotected, -> { preload(:user).preload(:classify_results).joins(:user).where(users: { protected: false }) }
  scope :with_photo, lambda {
    unprotected.where(media_type: Tweet::MediaType::PHOTO)
  }
  scope :classified_with_photo, lambda { |classification, result|
    with_photo
      .joins(:classify_results)
      .where(classify_results: { classification: classification, result: result, by_ml: false })
  }
  scope :pre_classified_with_photo, lambda { |classification, result|
    subquery = with_photo
               .joins(:classify_results).where(classify_results: { classification: classification, by_ml: false })
    with_photo
      .joins(:classify_results)
      .where(classify_results: { classification: classification, result: result, by_ml: true })
      .where.not(id: subquery)
  }
  scope :unclassified_with_photo, lambda {
    with_photo
      .left_outer_joins(:classify_results)
      .where(classify_results: { id: nil })
  }
  scope :pre_classified_with_sulemio_photo, lambda {
    # FIXME: pre_classified_with_photo を使うようになおしたい
    #pre_classified_with_photo(ClassifyResult::Classification::SULEMIO, true)
    preload(:classify_results)
      .joins(:user)
      .where(users: { protected: false })
      .where(media_type: Tweet::MediaType::PHOTO)
      .joins(:sulemio_by_ml_classify_results)
      .left_outer_joins(:by_user_classify_results)
      .where(by_user_classify_results: { tweet_id: nil })
  }
  scope :pre_classified_with_notsulemio_photo, lambda {
    pre_classified_with_photo(ClassifyResult::Classification::SULEMIO, false)
  }
  scope :classified_with_sulemio_photo, lambda {
    classified_with_photo(ClassifyResult::Classification::SULEMIO, true)
  }
  scope :classified_with_notsulemio_photo, lambda {
    classified_with_photo(ClassifyResult::Classification::SULEMIO, false)
  }
  scope :with_photo_without_user, lambda {
    where(media_type: Tweet::MediaType::PHOTO)
      .left_outer_joins(:user)
      .where(users: { id: nil })
  }
  # FIXME: start_date, end_date をStringで受け取るべきなのか再検討する
  # FIXME: テストを書く
  scope :by_date, lambda { |start_date, end_date|
    tweets = where.not(original_created_at: nil)
    if start_date.present? && end_date.present?
      tweets.where(original_created_at: DateTime.parse(start_date)..DateTime.parse(end_date))
    elsif start_date.present?
      tweets.where('original_created_at >= ?', DateTime.parse(start_date))
    elsif end_date.present?
      tweets.where('original_created_at <= ?', DateTime.parse(end_date))
    else
      tweets
    end
  }

  before_save do
    if classification
      self.classified = true
    end

    self.url ||= "https://twitter.com/_/status/#{t_id}"
  end

  # ユーザによる判断が存在する場合にtrueを返す
  # includes(:classify_results) しておく必要がある
  def classified?
    classify_results.map(&:by_ml).include?(false)
  end

  # ユーザによってスレミオだと判断されている場合にtrueを返す
  def sulemio?
    classified_for?(Classification::SULEMIO)
  end

  # ユーザによってミオリネだと判断されている場合にtrueを返す
  def miorine?
    classified_for?(Classification::MIORINE)
  end

  # ユーザによってスレッタだと判断されている場合にtrueを返す
  def suletta?
    classified_for?(Classification::SULETTA)
  end

  # ユーザによってclassificationだと判断されている場合にtrueを返す
  # includes(:classify_results) しておく必要がある
  # FIXME: classify_resultsの数が増えるとまずいかも？
  def classified_for?(classification)
    user_crs = classify_results.reject{ |cr| cr.by_ml }.select { |cr| cr.classification == classification }
    true_count = user_crs.count { |cr| cr.result }
    false_count = user_crs.count { |cr| !cr.result }
    ratio = true_count.to_f / (true_count + false_count)
    return ratio >= 0.5
  end

  def media_keys
    if raw_json
      h = JSON.parse(raw_json).deep_symbolize_keys
      if h.key?(:attachments)
        attachments = h[:attachments]
        if attachments.key?(:media_keys)
          return attachments[:media_keys]
        end
      end
    end
    return nil
  end

  def media_count
    keys = media_keys
    if keys
      return keys.count
    else
      return 0
    end
  end

  # api_response is a hash
  def self.create_many_from_api_response(tweets_response)
    tweets = tweets_response.bare_tweets
    tweets = tweets.map do |t|
      media_type = tweets_response.media_type_for_tweet(t)
      case media_type
      in Tweet::MediaType::PHOTO
        first_media_url = tweets_response.first_media_url_for_tweet(t)
      else
        first_media_url = nil
      end

      Tweet.find_or_create_with(
        tweet_hash: t,
        media_type: media_type,
        first_media_url: first_media_url
      )
    end
    Rails.logger.info "#{tweets.count} tweets inserted"
    return tweets
  end

  # 1ツィートを表すHashからレコードを検索する
  # レコードが存在しなければ, 1ツィートを表すHashとメディアタイプから新規レコードを追加する
  def self.find_or_create_with(tweet_hash:, media_type:, first_media_url: nil)
    tweet_hash = tweet_hash.with_indifferent_access
    case [tweet_hash, media_type]
    in [{ id: String => t_id, text: String => text }, MediaType::PHOTO | MediaType::NONE | MediaType::OTHER]
      user = User.find_or_create_by_uid(tweet_hash[:author_id]) if tweet_hash[:author_id]
      tweet = Tweet.find_or_initialize_by(t_id: t_id)
      tweet.body = text
      tweet.raw_json = tweet_hash.to_json
      tweet.media_type = media_type
      tweet.first_media_url = first_media_url
      tweet.original_created_at = tweet_hash[:created_at]
      tweet.user = user
      tweet.save! # 保存に失敗したら例外を投げる
      tweet
    end
  end

  # 検索で見つかったツィートを保存する
  # @param [User] access_user Twitter APIにアクセスするのに使用するユーザー
  # @param [String] query ツィート検索クエリ
  # @param [Integer] count 遡るページ数
  def self.save_searched_tweets(access_user:, query:, count: 1, pagination_token: nil)
    next_token = pagination_token
    count.times do
      _, next_token = save_searched_tweets_page(
        access_user: access_user,
        query: query,
        pagination_token: next_token
      )
      break if next_token.nil?
    end

    return next_token
  end

  # 検索で見つかったツィートを保存する（1ページ分）
  # @param [User] access_user Twitter APIにアクセスするのに使用するユーザー
  # @param [String] query ツィート検索クエリ
  # @param [String] pagination_token 次のページを取得するためのトークン
  def self.save_searched_tweets_page(access_user:, query:, pagination_token:)
    token = access_user.credential.token
    res = TwitterAPI::Client.tweets_search_recent(token, query, pagination_token)
    tweets_response = TwitterAPI::TweetsResponse.new(res)
    tweets = Tweet.create_many_from_api_response(tweets_response)
    return tweets, tweets_response.next_token
  end

  # ユーザーがnilのツィートを一括で更新する
  #
  # @param [User] access_user Twitter APIにアクセスするのに使用するユーザー
  # @return [Array<Tweet>] 更新したツィートの配列
  def self.bulk_update_has_no_user(access_user:, offset: 0, limit: 1000)
    tweet_has_no_user = where(media_type: Tweet::MediaType::PHOTO)
                        .order(created_at: :desc)
                        .left_outer_joins(:user)
                        .where(users: { id: nil })
                        .offset(offset)
                        .limit(limit)
    ret = []
    tweet_has_no_user.each_slice(100) do |tweets|
      response_hash = TwitterAPI::Client.tweets(access_user.credential.token, tweets.map(&:t_id))
      tweets_response = TwitterAPI::TweetsResponse.new(response_hash)
      ret += Tweet.create_many_from_api_response(tweets_response)
    end
    return ret
  end

  # t_id が重複しているツィートをcreated_atが最新のひとつを残して削除する
  def self.delete_duplicate_tweets(count: 1000)
    Tweet.group(:t_id).having('count(*) > 1').count.take(count).map do |t_id, _|
      Tweet.where(t_id: t_id).order(created_at: :desc).offset(1).destroy_all
    end
  end

  # データ移行用
  # classified が true で, classification が SULEMIO のツィートに sulemio,true の classify_result を追加する
  # classified が true で, classification が SULEMIO でないツィートに sulemio,false のclassify_result を追加する
  # @param [User] user 判別するユーザー
  def self.add_classify_result_for_sulemio(user:, limit: 10)
    tweets = Tweet.classified_without_classify_result.order(created_at: :desc).limit(limit)
    tweets.each do |t|
      # @type [Tweet]
      tweet = t
      if tweet.classification == Classification::SULEMIO
        tweet.classify_sulemio_by_user(user: user, result: true)
      else
        tweet.classify_sulemio_by_user(user: user, result: false)
      end
    end
  end
  scope :classified_without_classify_result, lambda {
    left_outer_joins(:classify_results).where(classified: true, classify_results: { id: nil })
  }

  # データ移行用
  #   - original_created_at が nil のツィートを検索する
  #   - raw_json に created_at が存在していれば, original_created_at に raw_json の created_at をセットする
  def self.bulk_update_original_created_at_from_raw_json(limit = 1, offset = 0)
    #while page = Tweet.where(original_created_at: nil).limit(limit).page(1)
    tweets = Tweet.where(original_created_at: nil).order(id: :asc).limit(limit).offset(offset)
    tweets.each do |t|
      t.update_original_created_at_from_raw_json
    end
    return nil
  end

  def update_original_created_at_from_raw_json
    Rails.logger.info "id: #{id}"
    json = JSON.parse(raw_json)
    if json.is_a?(Hash) && json['created_at'].present?
      self.original_created_at = json['created_at']
      save!
    end
  end

  # 判別結果を保存する
  # @param [User] user 判別したユーザー（機械学習による判別の場合はnil）
  # @param [String] classification 判別クラス
  # @param [Boolean] result 判別結果
  # @param [Boolean] by_ml 機械学習による判別かどうか
  # @return [ClassifyResult] 保存した判別結果
  # @raise [ActiveRecord::RecordInvalid] 判別結果の保存に失敗した場合
  def classify(user:, classification:, result:, by_ml:)
    classify_result = ClassifyResult.find_or_initialize_by(
      user: user,
      tweet: self,
      classification: classification
    )
    classify_result.result = result
    classify_result.by_ml = by_ml
    classify_result.save!
    return classify_result
  end

  # 機械学習による判別結果を保存する
  # @param [Boolean] result 判別結果
  # @return [ClassifyResult] 保存した判別結果
  def classify_sulemio_by_ml(result:)
    classify(user: nil, classification: Classification::SULEMIO, result: result, by_ml: true)
  end

  # ユーザーによる判別結果を保存する
  # @param [User] user 判別したユーザー
  # @param [Boolean] result 判別結果
  # @return [ClassifyResult] 保存した判別結果
  def classify_sulemio_by_user(user:, result:)
    classify(user: user, classification: Classification::SULEMIO, result: result, by_ml: false)
  end

  # 全てのAIによる判別結果を削除する
  def self.reset_predictions
    ClassifyResult.where(by_ml: true).destroy_all
  end

  # MLサービスを呼び出して判別結果を保存する
  # @return [String] 判別結果
  def predict
    logger.info "predicts tweet id: #{id}"

    unless predictable?
      increment_failed_prediction_count
      return false
    end

    # MLサービスにリクエストを投げる
    begin
      response = URI.open("http://ml:5080/?image_url=#{first_media_url}")
    rescue OpenURI::HTTPError => e
      logger.error("ML service returned error for id: #{id}, #{e.class}: #{e.message}")
      increment_failed_prediction_count
      return false
    rescue SocketError => e
      # MLサービスが起動していない場合は failed_prediction_count をインクリメントしない
      logger.error("ML service not responding id: #{id}, #{e.class}: #{e.message}")
      return false
    end

    # レスポンスをパースする
    response_hash = JSON.parse(response.read.chomp)
    class_name = response_hash['class_name']

    # 判別結果を保存する
    case class_name
    when 'SULEMIO'
      logger.info "classify as SULEMIO: #{id}"
      classify_sulemio_by_ml(result: true)
    when 'NOTSULEMIO'
      logger.info "classify as NOTSULEMIO: #{id}"
      classify_sulemio_by_ml(result: false)
    end

    return true
  end

  def increment_failed_prediction_count
    failed_prediction_count.nil? ? self.failed_prediction_count = 1 : self.failed_prediction_count += 1
    save!
  end

  def predictable?
    if media_type != MediaType::PHOTO
      logger.info "media_type is not photo: #{media_type}"
      return false
    elsif classify_results.exists?(by_ml: true)
      logger.info "already predicted: #{id}"
      return false
    elsif first_media_url.nil?
      logger.info "first_media_url is nil: #{id}"
      return false
    elsif first_media_url.empty?
      logger.info "first_media_url is empty: #{id}"
      return false
    end

    return true
  end
end
