require "test_helper"

class EmbedsControllerTest < ActionDispatch::IntegrationTest
  test "should render embed for valid calculator" do
    get calculator_embed_url(category: "finance", slug: "mortgage-calculator")
    assert_response :success
    # Should use embed layout (no main site nav or footer)
    assert_select "[data-controller='navbar']", false, "Embed should not render site navigation"
    assert_select "footer", false, "Embed should not render footer"
    # Should include Powered by CalcWise link
    assert_select "a[target='_blank']", /Powered by CalcWise/
    # Should include noindex meta
    assert_select "meta[name='robots'][content='noindex']"
  end

  test "should return not found for invalid calculator" do
    get calculator_embed_url(category: "finance", slug: "nonexistent-calculator")
    assert_response :not_found
  end

  test "should remove X-Frame-Options header for iframe embedding" do
    get calculator_embed_url(category: "finance", slug: "mortgage-calculator")
    assert_nil response.headers["X-Frame-Options"]
  end

  test "should set cache headers" do
    get calculator_embed_url(category: "finance", slug: "mortgage-calculator")
    assert_includes response.headers["Cache-Control"], "max-age=21600"
    assert_includes response.headers["Cache-Control"], "public"
  end

  test "embed_mode? returns true in embed context" do
    get calculator_embed_url(category: "health", slug: "bmi-calculator")
    assert_response :success
  end
end
