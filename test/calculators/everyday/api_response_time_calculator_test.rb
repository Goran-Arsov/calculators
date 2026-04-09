require "test_helper"

class Everyday::ApiResponseTimeCalculatorTest < ActiveSupport::TestCase
  test "calculates statistics for basic input" do
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: "100, 200, 300, 400, 500"
    ).call

    assert result[:valid]
    assert_equal 5, result[:count]
    assert_equal 300.0, result[:mean]
    assert_equal 300.0, result[:median]
    assert_equal 100.0, result[:min]
    assert_equal 500.0, result[:max]
  end

  test "calculates correct standard deviation" do
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: "10, 20, 30, 40, 50"
    ).call

    assert result[:valid]
    expected_std_dev = Math.sqrt(((10 - 30)**2 + (20 - 30)**2 + (30 - 30)**2 + (40 - 30)**2 + (50 - 30)**2) / 5.0)
    assert_in_delta expected_std_dev, result[:std_dev], 0.01
  end

  test "calculates percentiles with nearest-rank method" do
    # 10 values: 1,2,3,4,5,6,7,8,9,10
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: "1,2,3,4,5,6,7,8,9,10"
    ).call

    assert result[:valid]
    assert_equal 5.0, result[:p50]   # ceil(50/100 * 10) = 5th value = 5
    assert_equal 9.0, result[:p90]   # ceil(90/100 * 10) = 9th value = 9
    assert_equal 10.0, result[:p95]  # ceil(95/100 * 10) = 10th value = 10
    assert_equal 10.0, result[:p99]  # ceil(99/100 * 10) = 10th value = 10
  end

  test "handles single value" do
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: "42"
    ).call

    assert result[:valid]
    assert_equal 1, result[:count]
    assert_equal 42.0, result[:mean]
    assert_equal 42.0, result[:median]
    assert_equal 42.0, result[:min]
    assert_equal 42.0, result[:max]
    assert_equal 0.0, result[:std_dev]
    assert_equal 42.0, result[:p99]
  end

  test "handles decimal values" do
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: "1.5, 2.5, 3.5"
    ).call

    assert result[:valid]
    assert_equal 3, result[:count]
    assert_equal 2.5, result[:mean]
    assert_equal 2.5, result[:median]
  end

  test "handles unsorted input" do
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: "500, 100, 300, 200, 400"
    ).call

    assert result[:valid]
    assert_equal 100.0, result[:min]
    assert_equal 500.0, result[:max]
    assert_equal 300.0, result[:median]
  end

  test "handles duplicate values" do
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: "100, 100, 100, 100"
    ).call

    assert result[:valid]
    assert_equal 100.0, result[:mean]
    assert_equal 0.0, result[:std_dev]
  end

  test "returns error for empty input" do
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: ""
    ).call

    assert_not result[:valid]
    assert_includes result[:errors], "Response times cannot be empty"
  end

  test "returns error for invalid number" do
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: "100, abc, 200"
    ).call

    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid number") }
  end

  test "returns error for negative values" do
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: "100, -50, 200"
    ).call

    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("negative") }
  end

  test "handles extra whitespace and trailing commas" do
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: "  100 ,  200 ,  300  , "
    ).call

    assert result[:valid]
    assert_equal 3, result[:count]
    assert_equal 200.0, result[:mean]
  end

  test "p50 equals median" do
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: "10, 20, 30, 40, 50, 60, 70, 80, 90, 100"
    ).call

    assert result[:valid]
    assert_equal result[:median], result[:p50]
  end

  test "handles large dataset" do
    values = (1..1000).to_a.join(",")
    result = Everyday::ApiResponseTimeCalculator.new(
      response_times_csv: values
    ).call

    assert result[:valid]
    assert_equal 1000, result[:count]
    assert_equal 1.0, result[:min]
    assert_equal 1000.0, result[:max]
    assert_equal 500.5, result[:mean]
  end
end
