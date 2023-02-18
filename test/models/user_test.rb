# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  username          :string
#  name              :string
#  uid               :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  protected         :boolean
#  location          :string
#  url               :string
#  description       :string
#  profile_image_url :string
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

  test "APIレスポンスのHashからユーザを新規作成できる" do
    assert User.find_or_create_from_api_response(user1_hash)
    assert User.find_or_create_from_api_response(user2_hash)
  end

  test "APIレスポンスのHashの配列から複数のユーザを新規作成できる" do
    assert User.find_or_create_many_from_api_response(user_hashes)
  end

  test "APIレスポンスのHashからユーザを新規作成したとき、各カラムが正しく設定される" do
    u = User.find_or_create_from_api_response(user2_hash)
    assert_equal u.uid, user2_hash[:id]
    assert_equal u.name, user2_hash[:name]
    assert_equal u.username, user2_hash[:username]
    assert_equal u.protected, user2_hash[:protected]
    assert_equal u.location, user2_hash[:location]
    assert_equal u.url, user2_hash[:url]
    assert_equal u.description, user2_hash[:description]
    assert_equal u.profile_image_url, user2_hash[:profile_image_url]
  end
end
