module TwitterAPI
  class Client
    def self.get_user_me(user)
      case user
      in User
        credential = user.credential
        return TwitterAPI::Client.api_access(credential: credential, path: '/2/users/me')
      end
    end

    def self.fetch_timelines_reverse_chronological(user, pagination_token = nil)
      params = Client.params_for_fetch_timelines_reverse_chronological(pagination_token)
      res = Client.api_access(
        credential: user.credential,
        path: "/2/users/#{user.uid}/timelines/reverse_chronological",
        params: params
      )

      case res
      in Net::HTTPSuccess
        TweetsResponse.new(res)
      end
    end

    def self.params_for_fetch_timelines_reverse_chronological(pagination_token)
      params = {
        'tweet.fields' => 'text,referenced_tweets,attachments',
        'expansions' => 'referenced_tweets.id,attachments.media_keys',
        'media.fields' => 'type,preview_image_url,url'
      }
      if pagination_token
        params['pagination_token'] = pagination_token
      end
      return params
    end

    def self.api_access(credential:, path:, params: nil)
      client = Client.new(credential)
      res = client.get(path, params)
      return res
    end

    def initialize(credential)
      @credential = credential
    end

    def get(path, params = nil, retry: 1)
      http = build_http_client
      uri = build_uri(path, params)
      req = build_get_request(uri)
      res = http.request(req)
      return res
    end

    private

    def build_http_client
      http = Net::HTTP.new('api.twitter.com', 443)
      http.use_ssl = true
      return http
    end

    def build_uri(path, params)
      uri = URI.parse(path)
      if params
        uri.query = URI.encode_www_form(params)
      end
      return uri
    end

    def build_get_request(uri)
      req = Net::HTTP::Get.new(uri.to_s)
      req['Authorization'] = "Bearer #{@credential.token}"
      req['Content-type'] = 'application/json'
      return req
    end
  end

  #class Response
  #  def initialize(http_response)
  #    @http_response = http_response
  #  end
  #end

  #class UserResponse < Response

  #end

  class TweetsResponse
    attr_reader :http_response

    def initialize(http_response)
      @http_response = http_response
    end

    def raw_body
      @http_response.body
    end

    def body
      @body ||= JSON.parse(raw_body).with_indifferent_access
    end

    def data
      body[:data]
    end

    def includes
      body[:includes]
    end

    def meta
      body[:meta]
    end

    def included_tweets
      includes[:tweets]
    end

    def included_media
      includes[:media]
    end

    # APIレスポンスのハッシュから全ツィートを抜き出す
    #   - retweetは除外する
    #   - retweet元のツィートをincludesから拾って連結する
    def bare_tweets
      @bare_tweets ||= reject_retweet(data) + included_tweets
    end

    # 引数に与えられたtweetの1番目のメディアを取得する
    def first_media_for_tweet(tweet)
      medias_for_tweet(tweet)[0]
    end

    def first_media_url_for_tweet(tweet)
      first_media_for_tweet(tweet)[:url]
    end

    # 引数に与えられたtweetのメディアタイプを判別する
    def media_type_for_tweet(tweet)
      first_media = first_media_for_tweet(tweet)
      case first_media
      in type: 'photo'
        Tweet::MediaType::PHOTO
      in nil
        Tweet::MediaType::NONE
      else
        Tweet::MediaType::OTHER
      end
    end

    # 1ツィートとAPIレスポンスを渡して、media_keyが一致するmediaを取得する
    def medias_for_tweet(tweet)
      h = medias_hash
      return media_keys_for_tweet(tweet).map { |k| h[k] }
    end

    # 引数に与えられたtweetのmedia key の一覧を取得する
    def media_keys_for_tweet(tweet)
      tweet_s = tweet.with_indifferent_access

      keys = []
      if tweet_s in { attachments: { media_keys: Array => a } }
        keys += a
      end

      return keys
    end

    # media_key をキーにしたHashを返す
    def medias_hash
      h = {}

      if body in { includes: { media: Array => a } }
        h = a.map { |m| [m[:media_key], m] }.to_h
      end

      return h
    end

    # next_token を返す
    def next_token
      meta[:next_token]
    end

    private

    # 引数に与えられたtweetの配列からリツィートを除外する
    def reject_retweet(tweets)
      tweets.reject do |t|
        t in { referenced_tweets: [ {type: 'retweeted'} ] }
      end
    end
  end

  class ResponseOperator
    def initialize(response)
      case response
      in Hash
        @response = response.with_indifferent_access
      end
    end

    # APIレスポンスのハッシュから全ツィートを抜き出す
    #   - retweetは除外する
    #   - retweet元のツィートをincludesから拾って連結する
    def bare_tweets
      tweets = []

      # data からツィートを追加
      if @response in { data: Array => a }
        tweets += a
      end

      # RTを除外
      tweets.reject! do |t|
        t in { referenced_tweets: [ {type: 'retweeted'} ] }
      end

      # includesからツィートを追加
      if @response in { includes: { tweets: Array => a } }
        tweets += a
      end

      return tweets
    end

    # tweetのメディアタイプを判別する
    def media_type_for_tweet(tweet_hash)
      medias = medias_for_tweet(tweet_hash)
      case medias
      in [ { type: 'photo' } ]
        return Tweet::MediaType::PHOTO
      else
        return Tweet::MediaType::OTHER
      end
    end

    # 1ツィートとAPIレスポンスを渡して、media_keyが一致するmediaを取得する
    def medias_for_tweet(tweet_hash)
      h = medias_hash
      return media_keys(tweet_hash).map { |k| h[k] }
    end

    def media_keys(tweet_hash)
      tweet_hash_s = tweet_hash.with_indifferent_access

      keys = []
      if tweet_hash_s in { attachments: { media_keys: Array => a } }
        keys += a
      end

      return keys
    end

    # media_key をキーにしたHashを返す
    def medias_hash
      h = {}

      if @response in { includes: { media: Array => a } }
        h = a.map { |m| [m[:media_key], m] }.to_h
      end

      return h
    end

    # next_token を抜き出す
    def next_token
      @response[:meta][:next_token]
    end
  end
end