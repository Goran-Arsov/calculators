require "test_helper"

class Everyday::RobotsTxtCalculatorTest < ActiveSupport::TestCase
  test "generates default robots.txt" do
    result = Everyday::RobotsTxtCalculator.new(action: "generate").call
    assert result[:valid]
    assert_includes result[:output], "User-agent: *"
    assert_includes result[:output], "Allow: /"
  end

  test "generates robots.txt with custom rules" do
    rules = [ { user_agent: "Googlebot", disallow: [ "/private" ], allow: [ "/public" ] } ]
    result = Everyday::RobotsTxtCalculator.new(action: "generate", rules: rules).call
    assert result[:valid]
    assert_includes result[:output], "User-agent: Googlebot"
    assert_includes result[:output], "Disallow: /private"
    assert_includes result[:output], "Allow: /public"
  end

  test "generates robots.txt with sitemap" do
    result = Everyday::RobotsTxtCalculator.new(action: "generate", sitemap_url: "https://example.com/sitemap.xml").call
    assert result[:valid]
    assert_includes result[:output], "Sitemap: https://example.com/sitemap.xml"
    assert result[:has_sitemap]
  end

  test "tests allowed URL" do
    robots = "User-agent: *\nDisallow: /private\nAllow: /"
    result = Everyday::RobotsTxtCalculator.new(action: "test", test_robots: robots, test_url: "/public/page").call
    assert result[:valid]
    assert result[:results].any? { |r| r[:allowed] }
  end

  test "tests blocked URL" do
    robots = "User-agent: *\nDisallow: /private"
    result = Everyday::RobotsTxtCalculator.new(action: "test", test_robots: robots, test_url: "/private/secret").call
    assert result[:valid]
    assert result[:results].any? { |r| !r[:allowed] }
  end

  test "returns error for empty robots when testing" do
    result = Everyday::RobotsTxtCalculator.new(action: "test", test_robots: "", test_url: "/page").call
    assert_not result[:valid]
    assert_includes result[:errors], "robots.txt content cannot be empty"
  end

  test "returns error for empty URL when testing" do
    result = Everyday::RobotsTxtCalculator.new(action: "test", test_robots: "User-agent: *\nDisallow: /", test_url: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Test URL cannot be empty"
  end

  test "returns error for unsupported action" do
    result = Everyday::RobotsTxtCalculator.new(action: "validate").call
    assert_not result[:valid]
    assert_includes result[:errors], "Unsupported action: validate"
  end
end
