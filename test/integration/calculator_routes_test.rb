require "test_helper"

class CalculatorRoutesTest < ActionDispatch::IntegrationTest
  include CalculatorHelper

  test "all calculator routes return 200" do
    ALL_CATEGORIES.each do |category_slug, category|
      category[:calculators].each do |calc|
        path = send(calc[:path])
        get path
        assert_response :success, "Failed for #{calc[:name]} at #{path}"
      end
    end
  end

  test "all category pages return 200" do
    ALL_CATEGORIES.each_key do |slug|
      get category_path(slug)
      assert_response :success, "Failed for category: #{slug}"
    end
  end

  test "invalid category returns 404" do
    assert_raises(ActionController::UrlGenerationError) do
      get category_path("nonexistent")
    end
  end

  test "static pages return 200" do
    [about_path, privacy_policy_path, terms_of_service_path, contact_path, disclaimer_path].each do |path|
      get path
      assert_response :success, "Failed for #{path}"
    end
  end
end
