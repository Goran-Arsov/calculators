require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get finance category" do
    get category_url("finance")
    assert_response :success
    assert_select "h1", /Finance Calculators/
  end

  test "should get math category" do
    get category_url("math")
    assert_response :success
    assert_select "h1", /Math Calculators/
  end

  test "should get health category" do
    get category_url("health")
    assert_response :success
    assert_select "h1", /Health Calculators/
  end

  test "should return 404 for unknown category" do
    assert_raises(ActionController::UrlGenerationError) do
      get category_url("unknown")
    end
  end
end
