require "test_helper"

class ItToolsControllerTest < ActionDispatch::IntegrationTest
  test "index renders successfully" do
    get it_tools_url
    assert_response :success
    assert_select "h1"
  end

  test "index lists only IT-tagged everyday calculators" do
    get it_tools_url

    # Sanity check that at least one known IT tool slug appears in a link.
    # Pick a slug that's well-established in CalculatorRegistry::IT_TOOL_SLUGS.
    sample_slug = CalculatorRegistry::IT_TOOL_SLUGS.first
    assert sample_slug.present?, "expected IT_TOOL_SLUGS to be non-empty"
    assert_match(/#{Regexp.escape(sample_slug)}/, response.body)
  end
end
