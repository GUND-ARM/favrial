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
end
