require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
  end

  teardown do
    Rails.cache.clear
  end

  test "CRAWLER_USER_AGENTS pattern matches Googlebot" do
    ua = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    assert ua.match?(Rack::Attack::CRAWLER_USER_AGENTS)
  end

  test "CRAWLER_USER_AGENTS pattern matches bingbot" do
    ua = "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"
    assert ua.match?(Rack::Attack::CRAWLER_USER_AGENTS)
  end

  test "CRAWLER_USER_AGENTS pattern matches DuckDuckBot" do
    ua = "DuckDuckBot/1.1; (+http://duckduckgo.com/duckduckbot.html)"
    assert ua.match?(Rack::Attack::CRAWLER_USER_AGENTS)
  end

  test "CRAWLER_USER_AGENTS pattern does not match regular browser" do
    ua = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
    refute ua.match?(Rack::Attack::CRAWLER_USER_AGENTS)
  end

  test "Googlebot is not throttled even under heavy load" do
    googlebot_ua = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"

    # Hammer the home page well past the 300 req / 5 min throttle
    310.times do
      get "/", headers: { "User-Agent" => googlebot_ua }
      assert_response :success
    end
  end
end
