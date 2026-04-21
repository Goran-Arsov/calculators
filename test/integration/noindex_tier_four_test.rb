# frozen_string_literal: true

require "test_helper"

class NoindexTierFourTest < ActionDispatch::IntegrationTest
  test "Tier 4 head-term page emits noindex meta tag" do
    get "/finance/mortgage-calculator"
    assert_response :success
    assert_select 'meta[name="robots"][content*="noindex"]', { count: 1 },
      "mortgage calculator should be noindexed"
  end

  test "Tier 1 winnable page does not emit noindex" do
    get "/finance/solar-savings-calculator"
    assert_response :success
    assert_select 'meta[name="robots"][content*="noindex"]', { count: 0 },
      "solar savings calculator must remain indexable"
  end

  test "sitemap excludes noindexed Tier 4 URLs" do
    get "/sitemap-main.xml"
    assert_response :success
    Seo::NoindexList::PATHS.each do |path|
      assert_no_match %r{<loc>[^<]*#{Regexp.escape(path)}</loc>}, response.body,
        "sitemap should not contain noindexed path #{path}"
    end
  end

  test "sitemap still includes Tier 1 solar page" do
    get "/sitemap-main.xml"
    assert_response :success
    assert_match %r{<loc>[^<]*/finance/solar-savings-calculator</loc>}, response.body
  end
end
