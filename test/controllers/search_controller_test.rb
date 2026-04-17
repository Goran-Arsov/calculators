require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "index renders successfully with no query" do
    get search_url
    assert_response :success
    assert_select "h1"
  end

  test "index is noindex by default" do
    get search_url
    assert_select "meta[name='robots'][content*='noindex']"
  end

  test "index renders successfully with a query" do
    get search_url, params: { q: "mortgage" }
    assert_response :success
  end

  test "searching for a known calculator name returns results" do
    # "mortgage" is a finance calculator — exercises the matching_calculators path.
    get search_url, params: { q: "mortgage" }
    assert_response :success
    assert_match(/mortgage/i, response.body)
  end

  test "empty query returns no-results state without errors" do
    get search_url, params: { q: "   " }
    assert_response :success
  end

  test "gibberish query returns a success page with no match errors" do
    get search_url, params: { q: "qzx_nonexistent_#{SecureRandom.hex(4)}" }
    assert_response :success
  end
end
