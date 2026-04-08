require "test_helper"

class Api::RatingsControllerTest < ActionDispatch::IntegrationTest
  test "GET show returns star stats for a calculator" do
    CalculatorRating.create!(calculator_slug: "mortgage-calculator", direction: "up", score: 5, ip_hash: "h1")
    CalculatorRating.create!(calculator_slug: "mortgage-calculator", direction: "up", score: 4, ip_hash: "h2")
    CalculatorRating.create!(calculator_slug: "mortgage-calculator", direction: "down", score: 2, ip_hash: "h3")

    get "/api/ratings/mortgage-calculator"
    assert_response :success

    data = JSON.parse(response.body)
    assert_in_delta 3.7, data["average"], 0.1
    assert_equal 3, data["count"]
  end

  test "GET show returns zeros for unknown calculator" do
    get "/api/ratings/nonexistent"
    assert_response :success

    data = JSON.parse(response.body)
    assert_equal 0.0, data["average"]
    assert_equal 0, data["count"]
  end

  test "POST create saves a star rating" do
    assert_difference "CalculatorRating.count", 1 do
      post "/api/ratings/bmi-calculator", params: { score: 4 }, as: :json
    end
    assert_response :success

    data = JSON.parse(response.body)
    assert data["success"]
    assert_equal 4.0, data["average"]
    assert_equal 1, data["count"]
  end

  test "POST create rejects duplicate from same IP" do
    post "/api/ratings/loan-calculator", params: { score: 5 }, as: :json
    assert_response :success

    post "/api/ratings/loan-calculator", params: { score: 3 }, as: :json
    assert_response :unprocessable_entity

    data = JSON.parse(response.body)
    refute data["success"]
  end

  test "POST create sets direction based on score" do
    post "/api/ratings/calc-a", params: { score: 4 }, as: :json
    assert_response :success
    assert_equal "up", CalculatorRating.last.direction

    post "/api/ratings/calc-b", params: { score: 2 }, as: :json
    assert_response :success
    assert_equal "down", CalculatorRating.last.direction
  end

  test "POST create allows same IP for different calculators" do
    post "/api/ratings/calc-c", params: { score: 5 }, as: :json
    assert_response :success

    post "/api/ratings/calc-d", params: { score: 3 }, as: :json
    assert_response :success
  end

  test "GET show returns cache headers" do
    get "/api/ratings/mortgage-calculator", as: :json
    assert_response :success
    assert_match(/max-age=300/, response.headers["Cache-Control"])
  end

  test "POST create with score below 1 returns error" do
    assert_no_difference "CalculatorRating.count" do
      post "/api/ratings/mortgage-calculator", params: { score: 0 }, as: :json
    end
    assert_response :unprocessable_entity
    data = JSON.parse(response.body)
    assert_equal false, data["success"]
    assert_equal "Score must be between 1 and 5", data["error"]
  end

  test "POST create with score above 5 returns error" do
    assert_no_difference "CalculatorRating.count" do
      post "/api/ratings/mortgage-calculator", params: { score: 6 }, as: :json
    end
    assert_response :unprocessable_entity
    data = JSON.parse(response.body)
    assert_equal false, data["success"]
    assert_equal "Score must be between 1 and 5", data["error"]
  end

  test "POST create returns average and count on success" do
    post "/api/ratings/stats-test", params: { score: 4 }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert data["success"]
    assert data["average"].is_a?(Numeric)
    assert data["count"].is_a?(Integer)
  end
end
