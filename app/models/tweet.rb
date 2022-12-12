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
      :OTHER     # それ以外
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

  validates :t_id, uniqueness: true

  attribute :classified, default: false

  scope :classified_with_photo, lambda { |classification|
    where(classified: true, classification: classification).
      where(media_type: Tweet::MediaType::PHOTO).
      order(created_at: :desc)
  }
  scope :unclassified_with_photo, lambda {
    where(classified: false).
      where(media_type: Tweet::MediaType::PHOTO).
      order(created_at: :desc)
  }

  before_save do
    if classification
      self.classified = true
    end

    self.url ||= "https://twitter.com/_/status/#{t_id}"
  end

  def slemio?
    classification == Classification::SULEMIO
  end

  def miorine?
    classification == Classification::MIORINE
  end

  def suletta?
    classification == Classification::SULETTA
  end

  def self.fetch_timeline(fetch_count=1)
    credential = User.first.credential

    res = TwitterAPI::Client.api_access(credential: credential, path: '/2/users/me')
    case res
    in Net::HTTPSuccess
      json = JSON.parse(res.body)
      user_id = json['data']['id']
    end

    pagination_token = nil
    fetch_count.times do
      pagination_token = Tweet.fetch_timeline_once(credential, user_id, pagination_token)
      break unless pagination_token 
    end
  end

  def self.fetch_timeline_once(credential, user_id, pagination_token=nil)
    params = {
      'tweet.fields' => 'text,referenced_tweets,attachments',
      'expansions' => 'referenced_tweets.id,attachments.media_keys',
      'media.fields' => 'type'
    }
    if pagination_token
      params['pagination_token'] = pagination_token
    end

    res = TwitterAPI::Client.api_access(
      credential: credential,
      path: "/2/users/#{user_id}/timelines/reverse_chronological",
      params: params
    )
    case res
    in Net::HTTPSuccess
      api_response = JSON.parse(res.body).with_indifferent_access
      Tweet.create_many_from_api_response(api_response)
      return TwitterAPI::ResponseOperator.new(api_response).next_token
    end
  end

  # api_response is a hash
  def self.create_many_from_api_response(api_response)
    op = TwitterAPI::ResponseOperator.new(api_response)
    tweets = op.bare_tweets
    tweets = tweets.map do |t|
      media_type = op.media_type_for_tweet(t)
      Tweet.find_or_create_from_tweet_hash_with_media_type(
        tweet_hash: t,
        media_type: media_type
      )
    end
    return tweets
  end

  # 1ツィートを表すHashからレコードを検索する
  # レコードが存在しなければ, 1ツィートを表すHashとメディアタイプから新規レコードを追加する
  def self.find_or_create_from_tweet_hash_with_media_type(tweet_hash:, media_type:)
    tweet_hash = tweet_hash.with_indifferent_access
    case [tweet_hash, media_type]
    in [{ id: String => t_id, text: String => text }, MediaType::PHOTO | MediaType::OTHER]
      Tweet.find_or_create_by(t_id: t_id) do |t|
        t.body = text
        t.raw_json = hash.to_json
        t.media_type = media_type
      end
    end
  end
end
