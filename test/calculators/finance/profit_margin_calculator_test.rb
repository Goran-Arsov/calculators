require "test_helper"

class Finance::ProfitMarginCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "revenue=100, cost=60 → margin=40%" do
    result = Finance::ProfitMarginCalculator.new(revenue: 100, cost: 60).call
    assert result[:valid]
    assert_equal 40.0, result[:margin]
    assert_equal 40.0, result[:profit]
  end

  test "revenue=200, cost=100 → margin=50%" do
    result = Finance::ProfitMarginCalculator.new(revenue: 200, cost: 100).call
    assert result[:valid]
    assert_equal 50.0, result[:margin]
    assert_equal 100.0, result[:profit]
  end

  test "very small margin: revenue=100, cost=99" do
    result = Finance::ProfitMarginCalculator.new(revenue: 100, cost: 99).call
    assert result[:valid]
    assert_equal 1.0, result[:margin]
  end

  test "high margin: revenue=1000, cost=100" do
    result = Finance::ProfitMarginCalculator.new(revenue: 1000, cost: 100).call
    assert result[:valid]
    assert_equal 90.0, result[:margin]
  end

  # --- Validation errors ---

  test "error when revenue is zero" do
    result = Finance::ProfitMarginCalculator.new(revenue: 0, cost: 60).call
    refute result[:valid]
    assert_includes result[:errors], "Revenue must be positive"
  end

  test "error when cost is zero" do
    result = Finance::ProfitMarginCalculator.new(revenue: 100, cost: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Cost must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::ProfitMarginCalculator.new(revenue: 100, cost: 60)
    assert_equal [], calc.errors
  end
end
