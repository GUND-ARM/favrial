# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  username   :string
#  name       :string
#  uid        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "auth_hashからユーザを新規作成できる" do
    assert User.find_or_create_from_auth_hash(auth_hash)
  end

  test "Credentialが存在している" do
    u = User.find_or_create_from_auth_hash(auth_hash)
    assert_not_nil u.credential
  end

  test "find_or_createでCredentialが更新される" do
    u = User.find_or_create_from_auth_hash(auth_hash)
    id_1 = u.credential.id
    u = User.find_or_create_from_auth_hash(auth_hash)
    id_2 = u.credential.id
    assert_not_equal id_1, id_2
  end
end
