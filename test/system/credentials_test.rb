require "application_system_test_case"

class CredentialsTest < ApplicationSystemTestCase
  setup do
    @credential = credentials(:one)
  end

  test "visiting the index" do
    visit credentials_url
    assert_selector "h1", text: "Credentials"
  end

  test "should create credential" do
    visit credentials_url
    click_on "New credential"

    check "Expires" if @credential.expires
    fill_in "Expires at", with: @credential.expires_at
    fill_in "Token", with: @credential.token
    click_on "Create Credential"

    assert_text "Credential was successfully created"
    click_on "Back"
  end

  test "should update Credential" do
    visit credential_url(@credential)
    click_on "Edit this credential", match: :first

    check "Expires" if @credential.expires
    fill_in "Expires at", with: @credential.expires_at
    fill_in "Token", with: @credential.token
    click_on "Update Credential"

    assert_text "Credential was successfully updated"
    click_on "Back"
  end

  test "should destroy Credential" do
    visit credential_url(@credential)
    click_on "Destroy this credential", match: :first

    assert_text "Credential was successfully destroyed"
  end
end
