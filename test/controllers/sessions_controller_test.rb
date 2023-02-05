require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    use_omniauth
  end

  test "should create session" do
    get "/auth/twitter2/callback"
    assert_response :redirect
  end

  test "should destroy session" do
    get "/logout"
    assert_response :redirect
  end
end
