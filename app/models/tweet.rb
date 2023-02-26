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

  validates :t_id, uniqueness: true

  attribute :classified, default: false

  scope :unprotected, -> { joins(:user).where(users: { protected: false }) }
  scope :with_photo, lambda {
    unprotected.where(media_type: Tweet::MediaType::PHOTO).order(created_at: :desc)
  }
  scope :classified_with_photo, lambda { |classification|
    with_photo.where(classified: true, classification: classification)
  }
  scope :unclassified_with_photo, lambda {
    with_photo.where(classified: false)
  }

  before_save do
    if classification
      self.classified = true
    end

    self.url ||= "https://twitter.com/_/status/#{t_id}"
  end

  def sulemio?
    classification == Classification::SULEMIO
  end

  def miorine?
    classification == Classification::MIORINE
  end

  def suletta?
    classification == Classification::SULETTA
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
      if tweet_hash[:author_id]
        u = User.find_or_create_by_uid(tweet_hash[:author_id])
      else
        u = nil
      end
      Tweet.find_or_create_by(t_id: t_id) do |t|
        t.body = text
        t.raw_json = tweet_hash.to_json
        t.media_type = media_type
        t.first_media_url = first_media_url
        t.user = u
      end
    end
  end
end
