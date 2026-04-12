require "test_helper"

class Math::TaylorSeriesCalculatorTest < ActiveSupport::TestCase
  test "exp series first 3 terms" do
    result = Math::TaylorSeriesCalculator.new(function: "exp", num_terms: 3).call
    assert result[:valid]
    assert_equal 3, result[:terms].length
    assert_equal "e^x", result[:function_display]
    assert result[:is_maclaurin]
  end

  test "sin series first 3 terms are odd powers" do
    result = Math::TaylorSeriesCalculator.new(function: "sin", num_terms: 3).call
    assert result[:valid]
    powers = result[:terms].map { |t| t[:power] }
    assert_equal [1, 3, 5], powers
  end

  test "cos series first 3 terms are even powers" do
    result = Math::TaylorSeriesCalculator.new(function: "cos", num_terms: 3).call
    assert result[:valid]
    powers = result[:terms].map { |t| t[:power] }
    assert_equal [0, 2, 4], powers
  end

  test "ln(1+x) series first 3 terms" do
    result = Math::TaylorSeriesCalculator.new(function: "ln_1_plus_x", num_terms: 3).call
    assert result[:valid]
    assert_equal 3, result[:terms].length
    # coefficients: 1, -1/2, 1/3
    assert_in_delta 1.0, result[:terms][0][:coefficient], 1e-12
    assert_in_delta(-0.5, result[:terms][1][:coefficient], 1e-12)
    assert_in_delta(1.0 / 3, result[:terms][2][:coefficient], 1e-12)
  end

  test "geometric series 1/(1-x) has all coefficient 1" do
    result = Math::TaylorSeriesCalculator.new(function: "one_over_1_minus_x", num_terms: 5).call
    assert result[:valid]
    result[:terms].each do |t|
      assert_in_delta 1.0, t[:coefficient], 1e-12
    end
  end

  test "sinh series has odd powers only" do
    result = Math::TaylorSeriesCalculator.new(function: "sinh", num_terms: 3).call
    assert result[:valid]
    powers = result[:terms].map { |t| t[:power] }
    assert_equal [1, 3, 5], powers
  end

  test "cosh series has even powers only" do
    result = Math::TaylorSeriesCalculator.new(function: "cosh", num_terms: 3).call
    assert result[:valid]
    powers = result[:terms].map { |t| t[:power] }
    assert_equal [0, 2, 4], powers
  end

  test "atan series has odd powers only" do
    result = Math::TaylorSeriesCalculator.new(function: "atan", num_terms: 3).call
    assert result[:valid]
    powers = result[:terms].map { |t| t[:power] }
    assert_equal [1, 3, 5], powers
  end

  test "blank function returns error" do
    result = Math::TaylorSeriesCalculator.new(function: "").call
    refute result[:valid]
  end

  test "unsupported function returns error" do
    result = Math::TaylorSeriesCalculator.new(function: "gamma").call
    refute result[:valid]
  end

  test "num_terms below 1 returns error" do
    result = Math::TaylorSeriesCalculator.new(function: "exp", num_terms: 0).call
    refute result[:valid]
  end

  test "num_terms above 20 returns error" do
    result = Math::TaylorSeriesCalculator.new(function: "exp", num_terms: 21).call
    refute result[:valid]
  end

  test "polynomial string is not empty" do
    result = Math::TaylorSeriesCalculator.new(function: "exp", num_terms: 5).call
    assert result[:valid]
    assert result[:polynomial].length > 0
  end
end
