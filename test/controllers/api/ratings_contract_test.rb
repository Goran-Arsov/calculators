require "test_helper"

class Api::RatingsContractTest < ActionDispatch::IntegrationTest
  test "GET ratings returns JSON with average and count" do
    get "/api/ratings/mortgage-calculator", as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("average"), "Response missing 'average' key"
    assert json.key?("count"), "Response missing 'count' key"
  end

  test "POST ratings returns JSON with updated stats" do
    post "/api/ratings/mortgage-calculator", params: { score: 4 }, as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("average")
    assert json.key?("count")
    assert json["count"] >= 1
  end

  test "POST ratings with score saves successfully" do
    post "/api/ratings/mortgage-calculator", params: { score: 5 }, as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
  end
end
