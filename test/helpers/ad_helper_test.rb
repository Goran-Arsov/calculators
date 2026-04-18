require "test_helper"

class AdHelperTest < ActionView::TestCase
  include AdHelper

  # --- ad_provider ---

  test "ad_provider returns the configured provider string" do
    assert_kind_of String, ad_provider
    assert_equal AdHelper::AD_PROVIDER, ad_provider
  end

  # --- adsense_pub_id / adsense_enabled? ---

  test "adsense_pub_id returns the configured constant" do
    assert_equal AdHelper::ADSENSE_PUB_ID, adsense_pub_id
  end

  test "adsense_enabled? is false when pub id is the placeholder" do
    # The default in tests — no real AdSense ID configured.
    if AdHelper::ADSENSE_PUB_ID == "ca-pub-XXXXXXXXXXXXXXXX"
      refute adsense_enabled?
    end
  end

  # --- ad_slot_id ---

  test "ad_slot_id accepts a string position and returns a string" do
    assert_kind_of String, ad_slot_id("leaderboard")
  end

  test "ad_slot_id accepts a symbol position" do
    assert_equal ad_slot_id("leaderboard"), ad_slot_id(:leaderboard)
  end

  test "ad_slot_id returns empty string for an unknown position" do
    assert_equal "", ad_slot_id("does_not_exist")
  end

  test "ad_slot_id knows all documented positions" do
    %w[leaderboard in_results in_content sidebar anchor multiplex].each do |pos|
      assert_kind_of String, ad_slot_id(pos), "expected string for position #{pos}"
    end
  end

  # --- auto ads + script url ---

  test "adsense_script_url appends client param when auto ads are enabled" do
    define_singleton_method(:auto_ads_enabled?) { true }

    url = adsense_script_url
    assert_includes url, "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"
    assert_includes url, "?client=#{adsense_pub_id}"
  end

  test "adsense_script_url omits client param when auto ads are disabled" do
    define_singleton_method(:auto_ads_enabled?) { false }

    assert_equal "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js",
      adsense_script_url
  end
end
