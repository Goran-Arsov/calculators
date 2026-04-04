require "test_helper"

class RobotsControllerTest < ActionDispatch::IntegrationTest
  test "should get robots.txt with 200 and text content type" do
    get "/robots.txt"
    assert_response :success
    assert_match %r{text/plain}, response.content_type
  end

  test "robots.txt contains User-agent wildcard" do
    get "/robots.txt"
    assert_includes response.body, "User-agent: *"
  end

  test "robots.txt contains Allow directive" do
    get "/robots.txt"
    assert_includes response.body, "Allow: /"
  end

  test "robots.txt contains Sitemap URL" do
    get "/robots.txt"
    assert_match(/Sitemap:.*sitemap\.xml/, response.body)
  end

  test "robots.txt contains Mediapartners-Google user agent" do
    get "/robots.txt"
    assert_includes response.body, "Mediapartners-Google"
  end

  test "robots.txt contains AdsBot-Google user agent" do
    get "/robots.txt"
    assert_includes response.body, "AdsBot-Google"
  end
end
