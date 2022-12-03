require "test_helper"

class CredentialTest < ActiveSupport::TestCase
  test "credenials_hash から新しいCredentialを追加" do
    u = User.find_or_create_from_auth_hash(auth_hash)
    c = Credential.from_credentials_hash(auth_hash[:credentials])
    u.credential = c
    assert c.save
  end
end
