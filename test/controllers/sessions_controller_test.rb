require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  teardown do
    Rails.configuration.public_release = false
  end

  #test "should create session if beta user" do
  #  use_omniauth(auth_hash)
  #  get "/auth/twitter2/callback"
  #  assert_response :redirect
  #end

  #test "should not create session if not beta user" do
  #  use_omniauth(auth_hash_not_beta_user)
  #  get "/auth/twitter2/callback"
  #  assert_response :unauthorized
  #end

  #test "should create session if public release with non beta user" do
  #  Rails.configuration.public_release = true
  #  use_omniauth(auth_hash_not_beta_user)
  #  get "/auth/twitter2/callback"
  #  assert_response :redirect
  #  Rails.configuration.public_release = false
  #end

  test "should create session with non beta user" do
    use_omniauth(auth_hash_not_beta_user)
    get "/auth/twitter2/callback"
    assert_response :redirect
  end

  test "should destroy session" do
    get "/logout"
    assert_response :redirect
  end
end
