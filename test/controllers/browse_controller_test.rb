require "test_helper"

class BrowseControllerTest < ActionDispatch::IntegrationTest
  test "index renders successfully" do
    get browse_url
    assert_response :success
    assert_select "h1"
  end

  test "index renders a section anchor for every registered category" do
    # The view renders <div id="<slug>"> for each category — stable structural check
    # that doesn't break on title changes or HTML-escape differences.
    get browse_url
    CalculatorRegistry::ALL_CATEGORIES.each_key do |slug|
      assert_select "##{slug}", minimum: 1,
        message: "expected a section for category slug '#{slug}'"
    end
  end
end
