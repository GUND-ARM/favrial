# == Schema Information
#
# Table name: credentials
#
#  id            :bigint           not null, primary key
#  token         :string
#  expires_at    :integer
#  expires       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  refresh_token :string
#  user_id       :bigint
#
require "test_helper"

class CredentialTest < ActiveSupport::TestCase
  test "credenials_hash から新しいCredentialを追加" do
    u = User.find_or_create_from_auth_hash(auth_hash)
    c = Credential.from_credentials_hash(auth_hash[:credentials])
    u.credential = c
    assert c.save
  end

  test "access_token を渡して更新できる" do
    u = User.find_or_create_from_auth_hash(auth_hash)
    c = u.credential
    c.update_with_access_token(access_token)
    assert_equal(
      "bWU3S3RZRTNreHFTSHhLdEdyQjdzeWYwY2J6OW1BUWNsVlVWTWpFTjlzd3NHOjE2NzA5OTA3NTMxNjg6MToxOmF0OjE",
      c.access_token.token
    )
  end
end
