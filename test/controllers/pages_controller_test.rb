require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get privacy policy" do
    get privacy_policy_url
    assert_response :success
    assert_select "h1", /Privacy Policy/
  end

  test "should get terms of service" do
    get terms_of_service_url
    assert_response :success
    assert_select "h1", /Terms of Service/
  end

  test "should get about" do
    get about_url
    assert_response :success
    assert_select "h1", /About Calc Hammer/
  end
end
