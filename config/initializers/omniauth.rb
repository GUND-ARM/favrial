Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter2, ENV["TWITTER_CLIENT_ID"], ENV["TWITTER_CLIENT_SECRET"], callback_path: '/auth/twitter2/callback', scope: "tweet.read users.read"
end

OmniAuth.config.allowed_request_methods = [:post, :get] if Rails.env.development?
