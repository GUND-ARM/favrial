require "test_helper"

class CredentialTest < ActiveSupport::TestCase
  test "auth_hash からレコードを追加" do
    c = Credential.from_auth_hash(auth_hash)
    assert c.save
  end
end
