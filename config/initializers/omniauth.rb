Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter2, ENV["TWITTER_CLIENT_ID"], ENV["TWITTER_CLIENT_SECRET"], callback_path: '/auth/twitter2/callback', scope: "tweet.read users.read offline.access"
end

# FIXME: 脆弱性があるらしいのでPOSTのみでできるようにviewを修正する
#        参考: https://zenn.dev/koshilife/articles/b71f8cfcb50e33#%E3%82%A2%E3%83%83%E3%83%97%E3%82%B0%E3%83%AC%E3%83%BC%E3%83%89%E6%99%82%E3%81%AE%E5%AF%BE%E5%BF%9C
OmniAuth.config.allowed_request_methods = [:post, :get]
