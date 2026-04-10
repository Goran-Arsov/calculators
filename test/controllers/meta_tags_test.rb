require "test_helper"

class MetaTagsTest < ActionDispatch::IntegrationTest
  test "homepage has correct meta tags" do
    get root_path
    assert_response :success
    assert_select "title", /Calc Hammer/
    assert_select "meta[name='description']"
    assert_select "link[rel='canonical']"
  end

  test "calculator pages have OG tags" do
    get finance_mortgage_path
    assert_response :success
    assert_select "meta[property='og:title']"
    assert_select "meta[property='og:description']"
    assert_select "meta[property='og:url']"
    assert_select "meta[property='og:type']"
  end

  test "calculator pages have JSON-LD schema" do
    get finance_mortgage_path
    assert_response :success
    assert_select "script[type='application/ld+json']"
  end

  test "calculator pages have breadcrumb schema" do
    get finance_mortgage_path
    assert_response :success
    schemas = css_select("script[type='application/ld+json']")
    breadcrumb = schemas.find { |s| s.text.include?("BreadcrumbList") }
    assert breadcrumb, "BreadcrumbList schema missing"
    parsed = JSON.parse(breadcrumb.text)
    assert_equal "BreadcrumbList", parsed["@type"]
  end

  test "cache headers are set on calculator pages" do
    get finance_mortgage_path
    assert_response :success
    assert_match(/public/, response.headers["Cache-Control"])
    assert_match(/max-age/, response.headers["Cache-Control"])
  end

  test "cache headers include stale-while-revalidate" do
    get finance_mortgage_path
    assert_response :success
    assert_match(/stale-while-revalidate/, response.headers["Cache-Control"])
  end

  test "category pages have correct meta tags" do
    get category_path("finance")
    assert_response :success
    assert_select "title", /Finance/
    assert_select "meta[name='description']"
  end
end
