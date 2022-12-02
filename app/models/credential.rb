class Credential < ApplicationRecord
  validates :token, presence: true
  validates :refresh_token, presence: true
  validates :expires_at, presence: true
  validates :expires, presence: true

  def self.from_auth_hash(auth_hash)
    c = auth_hash["credentials"]
    Credential.new(
      {
        token: c["token"],
        refresh_token: c["refresh_token"],
        expires_at: c["expires_at"],
        expires: c["expires"]
      }
    )
  end

  #def self.create_from_auth_hash(auth_hash)
  #  c = Credential.from_auth_hash(auth_hash)
  #  c.save
  #end
end
