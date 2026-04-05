require "test_helper"

class Api::RatingsContractTest < ActionDispatch::IntegrationTest
  test "GET ratings returns JSON with up and down counts" do
    get "/api/ratings/mortgage-calculator", as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("up"), "Response missing 'up' key"
    assert json.key?("down"), "Response missing 'down' key"
    assert_kind_of Integer, json["up"]
    assert_kind_of Integer, json["down"]
  end

  test "POST ratings returns JSON with updated counts" do
    post "/api/ratings/mortgage-calculator", params: { direction: "up" }, as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("up")
    assert json.key?("down")
    assert json["up"] >= 1
  end

  test "POST ratings with invalid direction returns 422" do
    post "/api/ratings/mortgage-calculator", params: { direction: "invalid" }, as: :json
    assert_response :unprocessable_entity
  end
end
