require "test_helper"

class Math::MeanMedianModeCalculatorTest < ActiveSupport::TestCase
  # --- Mean ---

  test "mean of 1,2,3,4,5" do
    result = Math::MeanMedianModeCalculator.new(values: "1,2,3,4,5").call
    assert result[:valid]
    assert_equal 3.0, result[:mean]
  end

  test "mean of 10,20,30" do
    result = Math::MeanMedianModeCalculator.new(values: "10,20,30").call
    assert result[:valid]
    assert_equal 20.0, result[:mean]
  end

  # --- Median ---

  test "median of odd count" do
    result = Math::MeanMedianModeCalculator.new(values: "1,3,5,7,9").call
    assert result[:valid]
    assert_equal 5.0, result[:median]
  end

  test "median of even count" do
    result = Math::MeanMedianModeCalculator.new(values: "1,2,3,4").call
    assert result[:valid]
    assert_equal 2.5, result[:median]
  end

  test "median with unsorted input" do
    result = Math::MeanMedianModeCalculator.new(values: "9,1,5,3,7").call
    assert result[:valid]
    assert_equal 5.0, result[:median]
  end

  # --- Mode ---

  test "single mode" do
    result = Math::MeanMedianModeCalculator.new(values: "1,2,2,3,4").call
    assert result[:valid]
    assert_equal [ 2.0 ], result[:mode]
  end

  test "multiple modes (bimodal)" do
    result = Math::MeanMedianModeCalculator.new(values: "1,1,2,2,3").call
    assert result[:valid]
    assert_equal [ 1.0, 2.0 ], result[:mode]
  end

  test "no mode when all values unique" do
    result = Math::MeanMedianModeCalculator.new(values: "1,2,3,4,5").call
    assert result[:valid]
    assert_equal "No mode", result[:mode]
  end

  # --- Range, min, max ---

  test "range, min, and max" do
    result = Math::MeanMedianModeCalculator.new(values: "3,7,1,9,5").call
    assert result[:valid]
    assert_equal 8.0, result[:range]
    assert_equal 1.0, result[:min]
    assert_equal 9.0, result[:max]
  end

  # --- Standard deviation ---

  test "standard deviation of 2,4,4,4,5,5,7,9" do
    result = Math::MeanMedianModeCalculator.new(values: "2,4,4,4,5,5,7,9").call
    assert result[:valid]
    assert_in_delta 2.0, result[:std_dev], 0.001
  end

  # --- Sum and count ---

  test "sum and count" do
    result = Math::MeanMedianModeCalculator.new(values: "10,20,30").call
    assert result[:valid]
    assert_equal 60.0, result[:sum]
    assert_equal 3, result[:count]
  end

  # --- Validation ---

  test "error when no values provided" do
    result = Math::MeanMedianModeCalculator.new(values: "").call
    refute result[:valid]
    assert result[:errors].any?
  end

  test "error when only commas provided" do
    result = Math::MeanMedianModeCalculator.new(values: ",,").call
    refute result[:valid]
  end

  # --- Edge cases ---

  test "single value" do
    result = Math::MeanMedianModeCalculator.new(values: "42").call
    assert result[:valid]
    assert_equal 42.0, result[:mean]
    assert_equal 42.0, result[:median]
    assert_equal 0.0, result[:range]
    assert_equal 0.0, result[:std_dev]
  end

  test "negative values" do
    result = Math::MeanMedianModeCalculator.new(values: "-5,-3,-1,1,3,5").call
    assert result[:valid]
    assert_equal 0.0, result[:mean]
    assert_equal 0.0, result[:median]
  end

  test "decimal values" do
    result = Math::MeanMedianModeCalculator.new(values: "1.5,2.5,3.5").call
    assert result[:valid]
    assert_equal 2.5, result[:mean]
    assert_equal 2.5, result[:median]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::MeanMedianModeCalculator.new(values: "1,2,3")
    assert_equal [], calc.errors
  end
end
