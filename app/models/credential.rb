class Credential < ApplicationRecord
  def self.from_auth_hash(auth_hash)
    c = auth_hash.credentials
    Credential.create(
      {
        token: c.token,
        expires_at: c.expires_at,
        expires: c.expires
      }
    )
  end
end
