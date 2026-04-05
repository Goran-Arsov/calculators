require "test_helper"

class Api::RatingsControllerTest < ActionDispatch::IntegrationTest
  test "GET show returns counts for a calculator" do
    CalculatorRating.create!(calculator_slug: "mortgage-calculator", direction: "up", ip_hash: "h1")
    CalculatorRating.create!(calculator_slug: "mortgage-calculator", direction: "up", ip_hash: "h2")
    CalculatorRating.create!(calculator_slug: "mortgage-calculator", direction: "down", ip_hash: "h3")

    get "/api/ratings/mortgage-calculator"
    assert_response :success

    data = JSON.parse(response.body)
    assert_equal 2, data["up"]
    assert_equal 1, data["down"]
  end

  test "GET show returns zeros for unknown calculator" do
    get "/api/ratings/nonexistent"
    assert_response :success

    data = JSON.parse(response.body)
    assert_equal 0, data["up"]
    assert_equal 0, data["down"]
  end

  test "POST create saves a rating" do
    assert_difference "CalculatorRating.count", 1 do
      post "/api/ratings/bmi-calculator", params: { direction: "up" }, as: :json
    end
    assert_response :success

    data = JSON.parse(response.body)
    assert data["success"]
    assert_equal 1, data["up"]
    assert_equal 0, data["down"]
  end

  test "POST create rejects duplicate from same IP" do
    post "/api/ratings/loan-calculator", params: { direction: "up" }, as: :json
    assert_response :success

    post "/api/ratings/loan-calculator", params: { direction: "down" }, as: :json
    assert_response :unprocessable_entity

    data = JSON.parse(response.body)
    refute data["success"]
  end

  test "POST create rejects invalid direction" do
    post "/api/ratings/calorie-calculator", params: { direction: "sideways" }, as: :json
    assert_response :unprocessable_entity
  end

  test "POST create allows same IP for different calculators" do
    post "/api/ratings/calc-a", params: { direction: "up" }, as: :json
    assert_response :success

    post "/api/ratings/calc-b", params: { direction: "down" }, as: :json
    assert_response :success
  end
end
