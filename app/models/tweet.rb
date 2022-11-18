class Tweet < ApplicationRecord
  # こんなかんじで定数の一覧がとれる
  #
  # Tweet::Classification.constants.each do |k|
  #   p Tweet::Classification.const_get(k)
  # end
  #
  module Classification
    SULEMIO = 'sulemio'.freeze
    OTHER = 'other'.freeze
  end

  module MediaType
    PHOTO = 'photo'.freeze
    OTHER = 'other'.freeze
  end

  validates :t_id, uniqueness: true

  attribute :classified, default: false

  before_save do
    self.classified = classification == Classification::SULEMIO ||
                      classification == Classification::OTHER

    self.url ||= "https://twitter.com/_/status/#{t_id}"
  end

  def self.fetch_timeline
    token = Credential.order(created_at: :desc).first.token

    res = Tweet.api_access(token, '/2/users/me')
    case res
    in Net::HTTPSuccess
      json = JSON.parse(res.body)
      user_id = json['data']['id']
    end

    pagination_token = nil
    5.times do
      pagination_token = Tweet.fetch_timeline_once(token, user_id, pagination_token)
      break unless pagination_token 
    end
  end

  def self.fetch_timeline_once(token, user_id, pagination_token=nil)
    params = {
      'tweet.fields' => 'text,referenced_tweets,attachments',
      'expansions' => 'referenced_tweets.id,attachments.media_keys',
      'media.fields' => 'type'
    }
    if pagination_token
      params['pagination_token'] = pagination_token
    end

    res = Tweet.api_access(token, "/2/users/#{user_id}/timelines/reverse_chronological", params)
    case res
    in Net::HTTPSuccess
      json = JSON.parse(res.body).with_indifferent_access
    end

    medias_hash = {}
    case json
    in { includes: { media: Array => medias } }
      medias.each do |m|
        medias_hash[m["media_key"]] = {"type" => m["type"]}
      end
    else
      # do nothing
    end

    case data = json['data']
    in Array
      tweets = data
    end

    case json
    in { includes: { tweets: Array => ts } }
      tweets += ts
    else
      # do not anything
    end

    tweets = tweets.reject do |t|
      t['referenced_tweets'] &&
        t['referenced_tweets'][0] &&
        t['referenced_tweets'][0]['type'] == 'retweeted'
    end
    tweets = tweets.map do |t|
      case t
      in { attachments: { media_keys: media_keys } }
        k = media_keys[0]
        t['type'] = medias_hash[k]['type'] if medias_hash[k]
      else
        # do nothing
      end
      t
    end
    tweets.each do |t|
      Tweet.find_or_create_from_tweet_hash(t)
    end

    json['meta']['next_token']
  end

  def self.api_access(token, path, params=nil)
    uri = URI.parse(path)
    if params
      uri.query = URI.encode_www_form(params)
    end
    http = Net::HTTP.new('api.twitter.com', 443)
    http.use_ssl = true
    req = Net::HTTP::Get.new(uri.to_s)
    req['Authorization'] = "Bearer #{token}"
    req['Content-type'] = 'application/json'
    res = http.request(req)
  end

  # APIレスポンスのhashから複数のTweetを作成する
  def self.create_from_response_hash(hash)
    tweets = hash['data']
    tweets.each do |t|
      Tweet.find_or_create_from_tweet_hash(t)
    end
  end

  # t_id が id に一致するTweetが見つからなければレコード追加
  def self.find_or_create_from_tweet_hash(hash)
    #
    # example of `hash`:
    #   {
    #     "edit_history_tweet_ids": [
    #       "1591727016780660736"
    #     ],
    #     "id": "1591727016780660736",
    #     "text": "7話でミオリネさんに身惚れてくんないかな〜〜〜かな〜〜〜！！！！！！！"
    #   }
    #
    case [hash['id'], hash['text']]
    in [String, String]
      t_id = hash['id']
      text = hash['text']
    end
    if hash['type'] == 'photo'
      type = Tweet::MediaType::PHOTO
    else
      type = Tweet::MediaType::OTHER
    end
    Tweet.find_or_create_by(t_id: t_id) do |t|
      t.body = text
      t.raw_json = hash.to_json
      t.media_type = type
    end
  end
end
