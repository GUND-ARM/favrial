# == Schema Information
#
# Table name: tweets
#
#  id              :bigint           not null, primary key
#  t_id            :string
#  body            :text
#  url             :string
#  raw_json        :text
#  media_type      :string
#  classification  :string
#  classified      :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  first_media_url :string
#  user_id         :bigint
#
class Tweet < ApplicationRecord
  # こんなかんじで定数の一覧がとれる
  #
  # Tweet::Classification.constants.each do |k|
  #   p Tweet::Classification.const_get(k)
  # end
  #
  # スレミオ分類
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

  validates :t_id, uniqueness: true

  attribute :a_classification, :string # 元々あったclassificationのかわりに使う
  attribute :classified, default: false

  scope :unprotected, -> { joins(:user).where(users: { protected: false }) }
  scope :with_photo, lambda {
    unprotected.where(media_type: Tweet::MediaType::PHOTO).order(created_at: :desc)
  }
  scope :classified_with_photo, lambda { |classification|
    with_photo
      .joins(:classify_results)
      .where(classify_results: { classification: classification, result: true, by_ml: false })
  }
  scope :pre_classified_with_photo, lambda { |classification|
    with_photo
      .joins(:classify_results)
      .where(classify_results: { classification: classification, result: true, by_ml: true })
  }
  scope :unclassified_with_photo, lambda {
    with_photo.where(classified: false)
  }
  scope :pre_classified_with_sulemio_photo, lambda {
    pre_classified_with_photo(ClassifyResult::Classification::SULEMIO)
  }
  scope :classified_with_sulemio_photo, lambda {
    classified_with_photo(ClassifyResult::Classification::SULEMIO)
  }
  scope :with_photo_without_user, lambda {
    where(media_type: Tweet::MediaType::PHOTO)
      .left_outer_joins(:user)
      .where(users: { id: nil })
  }

  before_save do
    if classification
      self.classified = true
    end

    self.url ||= "https://twitter.com/_/status/#{t_id}"
  end

  # ユーザによる判断が存在する場合にtrueを返す
  def sulemio?
    classified_by?(Classification::SULEMIO)
  end

  # ユーザによる判断が存在する場合にtrueを返す
  def miorine?
    classified_by?(Classification::MIORINE)
  end

  # ユーザによる判断が存在する場合にtrueを返す
  def suletta?
    classified_by?(Classification::SULETTA)
  end

  # ユーザによる判断が存在する場合にtrueを返す
  def classified_by?(classification)
    classify_results.where(classification: classification, by_ml: false).exists?
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
      tweet.user = user
      tweet.save! # 保存に失敗したら例外を投げる
      tweet
    end
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

  # 判別をおこなう
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
end
