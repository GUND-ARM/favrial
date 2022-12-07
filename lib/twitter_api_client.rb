class TwitterAPIClient
  def self.api_access(credential:, path:, params: nil)
    client = TwitterAPIClient.new(credential)
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
