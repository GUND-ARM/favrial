require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "auth_hashからユーザを新規作成できる" do
    assert User.find_or_create_from_auth_hash(auth_hash)
  end

  test "Credentialが存在している" do
    u = User.find_or_create_from_auth_hash(auth_hash)
    assert_not_nil u.credential
  end
end
