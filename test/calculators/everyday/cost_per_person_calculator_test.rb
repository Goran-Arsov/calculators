require "test_helper"

class Everyday::CostPerPersonCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic split: $120 among 4 people" do
    result = Everyday::CostPerPersonCalculator.new(total_cost: 120, people: 4).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 30.0, result[:cost_per_person]
    assert_equal 120.0, result[:grand_total]
    assert_equal 30.0, result[:base_per_person]
  end

  test "split with tip: $100, 2 people, 20% tip" do
    result = Everyday::CostPerPersonCalculator.new(total_cost: 100, people: 2, tip_percent: 20).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 60.0, result[:cost_per_person]
    assert_equal 120.0, result[:grand_total]
    assert_equal 20.0, result[:tip_amount]
    assert_equal 10.0, result[:tip_per_person]
  end

  test "split with tax and tip: $100, 4 people, 18% tip, 8% tax" do
    result = Everyday::CostPerPersonCalculator.new(total_cost: 100, people: 4, tip_percent: 18, tax_percent: 8).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 126.0, result[:grand_total]
    assert_equal 31.5, result[:cost_per_person]
    assert_equal 8.0, result[:tax_amount]
    assert_equal 18.0, result[:tip_amount]
    assert_equal 4.5, result[:tip_per_person]
    assert_equal 2.0, result[:tax_per_person]
  end

  test "single person gets full cost" do
    result = Everyday::CostPerPersonCalculator.new(total_cost: 50, people: 1).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 50.0, result[:cost_per_person]
    assert_equal 50.0, result[:grand_total]
  end

  test "zero tip and tax defaults" do
    result = Everyday::CostPerPersonCalculator.new(total_cost: 80, people: 2).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0.0, result[:tax_amount]
    assert_equal 0.0, result[:tip_amount]
    assert_equal 40.0, result[:cost_per_person]
  end

  # --- Validation errors ---

  test "error when total cost is zero" do
    result = Everyday::CostPerPersonCalculator.new(total_cost: 0, people: 2).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Total cost must be greater than zero"
  end

  test "error when people is zero" do
    result = Everyday::CostPerPersonCalculator.new(total_cost: 100, people: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Number of people must be at least 1"
  end

  test "error when tip percent is negative" do
    result = Everyday::CostPerPersonCalculator.new(total_cost: 100, people: 2, tip_percent: -5).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Tip percent cannot be negative"
  end

  test "error when tax percent is negative" do
    result = Everyday::CostPerPersonCalculator.new(total_cost: 100, people: 2, tax_percent: -3).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Tax percent cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::CostPerPersonCalculator.new(total_cost: "120", people: "4", tip_percent: "15", tax_percent: "8").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 30.0, result[:base_per_person]
    assert_equal 18.0, result[:tip_amount]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::CostPerPersonCalculator.new(total_cost: 100, people: 2)
    assert_equal [], calc.errors
  end

  test "large group split with decimals" do
    result = Everyday::CostPerPersonCalculator.new(total_cost: 100, people: 3).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 33.33, result[:cost_per_person]
  end
end
