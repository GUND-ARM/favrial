module TwitterAPI
  class Client
    # tokenの所有者であるユーザの情報を取得する
    #
    # @param [String] token アクセストークン
    # @return [Hash] APIレスポンスのハッシュ
    def self.users_me(token)
      new(token).users_me
    end

    # @param [String] token アクセストークン
    # @param [Array<String>] user_ids ユーザーIDの配列
    def self.users(token, user_ids)
      new(token).users(user_ids)
    end

    # @param [String] token アクセストークン
    # @param [Array<String>] tweet_ids ツィートIDの配列
    def self.tweets(token, tweet_ids)
      new(token).tweets(tweet_ids)
    end

    # @param [User] user APIアクセスするユーザー
    # @param [String] pagination_token ページネーショントークン
    # @return [TweetsResponse] ツィートのレスポンス
    def self.fetch_timelines_reverse_chronological(user, pagination_token = nil)
      params = Client.params_for_fetch_timelines_reverse_chronological(pagination_token)
      res = Client.api_access(
        credential: user.credential,
        path: "/2/users/#{user.uid}/timelines/reverse_chronological",
        params: params
      )

      case res
      in Net::HTTPSuccess
        TweetsResponse.new(res.body)
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
      return Client.new(credential.token).api_access(path: path, params: params)
    end

    def initialize(token)
      @token = token
    end

    # tokenの所有者であるユーザの情報を取得する
    #
    # @return [Hash] APIレスポンスのハッシュ
    def users_me
      res = api_access(
        path: '/2/users/me',
        params: user_params
      )
      return JSON.parse(res.body).deep_symbolize_keys
    end

    # idsで指定したユーザーの情報を取得する
    #   - ユーザーIDは最大100個まで指定可能
    #
    # @param [Array<String>] ids ユーザーIDの配列
    # @return [Hash] APIレスポンスのハッシュ
    def users(ids)
      res = api_access(
        path: '/2/users',
        params: users_params(ids)
      )
      return JSON.parse(res.body).deep_symbolize_keys
    end

    # @param [Array<String>] ids ツィートIDの配列
    # @return [Hash] APIレスポンスのハッシュ
    def tweets(ids)
      res = api_access(
        path: '/2/tweets',
        params: tweets_params(ids)
      )
      return JSON.parse(res.body).deep_symbolize_keys
    end

    # @param [String] path APIのパス
    # @param [Hash] params APIリクエストのパラメータ
    def api_access(path:, params: nil)
      res = get(path, params)
      return res
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
      req['Authorization'] = "Bearer #{@token}"
      req['Content-type'] = 'application/json'
      return req
    end

    # @return [Hash] APIリクエストのパラメータ
    def user_params
      {
        'user.fields' => 'created_at,description,entities,id,location,name,' \
        'pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld'
      }
    end

    # @param [Array<String>] ids ユーザーIDの配列
    # @return [Hash] APIリクエストのパラメータ
    def users_params(ids)
      user_params.merge({ 'ids' => ids.join(',') })
    end

    # @param [Array<String>] ids ツィートIDの配列
    # @return [Hash] APIリクエストのパラメータ
    def tweets_params(ids)
      {
        'ids' => ids.join(','),
        'tweet.fields' => 'text,created_at,author_id,referenced_tweets,attachments,lang',
        'expansions' => 'referenced_tweets.id,attachments.media_keys',
        'media.fields' => 'type,preview_image_url,url'
      }
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
    attr_reader :raw_body

    def initialize(http_response_body)
      @raw_body = http_response_body
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
      if includes && includes[:tweets]
        includes[:tweets]
      else
        []
      end
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
end
