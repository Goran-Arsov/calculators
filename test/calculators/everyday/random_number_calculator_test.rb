require "test_helper"

class Everyday::RandomNumberCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "generates a single random number in range" do
    result = Everyday::RandomNumberCalculator.new(min: 1, max: 10, count: 1).call
    assert result[:valid]
    assert_equal 1, result[:numbers].size
    assert result[:numbers].first.between?(1, 10)
    assert_equal 1, result[:min]
    assert_equal 10, result[:max]
  end

  test "generates multiple random numbers" do
    result = Everyday::RandomNumberCalculator.new(min: 1, max: 100, count: 10).call
    assert result[:valid]
    assert_equal 10, result[:numbers].size
    result[:numbers].each { |n| assert n.between?(1, 100) }
  end

  test "generates unique numbers when requested" do
    result = Everyday::RandomNumberCalculator.new(min: 1, max: 10, count: 10, unique: true).call
    assert result[:valid]
    assert_equal 10, result[:numbers].size
    assert_equal 10, result[:numbers].uniq.size
    assert_equal false, result[:has_duplicates]
  end

  test "unique mode caps at range size" do
    result = Everyday::RandomNumberCalculator.new(min: 1, max: 5, count: 10, unique: true).call
    assert result[:valid]
    assert_equal 5, result[:numbers].size
    assert_equal 5, result[:numbers].uniq.size
  end

  test "generates numbers with equal min and max" do
    result = Everyday::RandomNumberCalculator.new(min: 5, max: 5, count: 3).call
    assert result[:valid]
    assert_equal [ 5, 5, 5 ], result[:numbers]
  end

  test "generates negative numbers" do
    result = Everyday::RandomNumberCalculator.new(min: -10, max: -1, count: 5).call
    assert result[:valid]
    result[:numbers].each { |n| assert n.between?(-10, -1) }
  end

  test "count of 1 returns single number" do
    result = Everyday::RandomNumberCalculator.new(min: 1, max: 1000000).call
    assert result[:valid]
    assert_equal 1, result[:count]
  end

  test "has_duplicates is true when duplicates exist" do
    result = Everyday::RandomNumberCalculator.new(min: 1, max: 2, count: 100).call
    assert result[:valid]
    assert result[:has_duplicates]
  end

  test "max count of 1000 works" do
    result = Everyday::RandomNumberCalculator.new(min: 1, max: 1000000, count: 1000).call
    assert result[:valid]
    assert_equal 1000, result[:numbers].size
  end

  # --- Validation errors ---

  test "error when min is greater than max" do
    result = Everyday::RandomNumberCalculator.new(min: 10, max: 1).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("less than or equal") }
  end

  test "error when count is 0" do
    result = Everyday::RandomNumberCalculator.new(min: 1, max: 10, count: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("between 1") }
  end

  test "error when count exceeds maximum" do
    result = Everyday::RandomNumberCalculator.new(min: 1, max: 10, count: 1001).call
    assert_equal false, result[:valid]
  end

  test "error when count is negative" do
    result = Everyday::RandomNumberCalculator.new(min: 1, max: 10, count: -5).call
    assert_equal false, result[:valid]
  end

  test "string coercion works" do
    result = Everyday::RandomNumberCalculator.new(min: "1", max: "10", count: "5").call
    assert result[:valid]
    assert_equal 5, result[:numbers].size
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::RandomNumberCalculator.new(min: 1, max: 10)
    assert_equal [], calc.errors
  end
end
