require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_select "h1", /Free Online/
  end

  test "homepage contains CalcWise branding" do
    get root_url
    assert_select "h1", /calculator/i
  end

  test "homepage includes JSON-LD schema" do
    get root_url
    assert_select "script[type='application/ld+json']", minimum: 1
  end

  test "homepage includes organization schema" do
    get root_url
    schemas = css_select("script[type='application/ld+json']").map { |s| JSON.parse(s.text) }
    org_schema = schemas.find { |s| s["@type"] == "Organization" }
    assert_not_nil org_schema, "Expected Organization schema on homepage"
    assert_equal "CalcWise", org_schema["name"]
  end

  test "homepage includes website schema" do
    get root_url
    schemas = css_select("script[type='application/ld+json']").map { |s| JSON.parse(s.text) }
    website_schema = schemas.find { |s| s["@type"] == "WebSite" }
    assert_not_nil website_schema, "Expected WebSite schema on homepage"
    assert_equal "CalcWise", website_schema["name"]
  end
end
