class Credential < ApplicationRecord
  belongs_to :user

  validates :token, presence: true
  validates :refresh_token, presence: true
  validates :expires_at, presence: true
  validates :expires, presence: true

  def self.from_credentials_hash(credentials_hash)
    Credential.new(
      {
        token: credentials_hash["token"],
        refresh_token: credentials_hash["refresh_token"],
        expires_at: credentials_hash["expires_at"],
        expires: credentials_hash["expires"]
      }
    )
  end

  # ahead に指定した秒数ぶんはやめにexpiredと判断する
  def expired?(ahead = 600)
    expires_at <= DateTime.now.to_i + ahead
  end

  def refresh
    current_access_token = access_token
    new_access_token = current_access_token.refresh!
    update_with_access_token(new_access_token)
  end

  def update_with_access_token(new_access_token)
    case new_access_token
    in OAuth2::AccessToken
      self.token = new_access_token.token
      self.refresh_token = new_access_token.refresh_token
      self.expires_at = new_access_token.expires_at
      self.expires = new_access_token.expires?
      save
    end
  end

  def access_token
    client = oauth2_client
    OAuth2::AccessToken.new(
      client,
      token,
      refresh_token: refresh_token,
      expires_at: expires_at
    )
  end

  private

  def oauth2_client
    OAuth2::Client.new(
      ENV['TWITTER_CLIENT_ID'],
      ENV['TWITTER_CLIENT_SECRET'],
      site: 'https://api.twitter.com',
      token_url: "2/oauth2/token",
      authorize_url: "https://twitter.com/i/oauth2/authorize"
    )
  end
end
