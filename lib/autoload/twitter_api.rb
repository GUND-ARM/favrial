module TwitterAPI
  class Client
    def self.api_access(credential:, path:, params: nil)
      client = Client.new(credential)
      res = client.get(path, params)
      return res
    end

    def initialize(credential)
      @credential = credential
    end

    def get(path, params = nil)
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
  end
end
