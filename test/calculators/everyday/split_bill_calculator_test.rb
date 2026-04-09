require "test_helper"

class Everyday::SplitBillCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "subtotal=100, tip=18%, tax=8%, people=4 → tip=18, tax=8, total=126, per_person=31.50" do
    result = Everyday::SplitBillCalculator.new(subtotal: 100, tip_percent: 18, tax_percent: 8, num_people: 4).call
    assert_equal true, result[:valid]
    assert_equal 18.0, result[:tip_amount]
    assert_equal 8.0, result[:tax_amount]
    assert_equal 126.0, result[:total]
    assert_equal 31.5, result[:per_person]
  end

  test "no tip or tax, split between 2" do
    result = Everyday::SplitBillCalculator.new(subtotal: 50, tip_percent: 0, tax_percent: 0, num_people: 2).call
    assert_equal true, result[:valid]
    assert_equal 0.0, result[:tip_amount]
    assert_equal 0.0, result[:tax_amount]
    assert_equal 50.0, result[:total]
    assert_equal 25.0, result[:per_person]
  end

  test "single person pays full amount" do
    result = Everyday::SplitBillCalculator.new(subtotal: 80, tip_percent: 20, tax_percent: 10, num_people: 1).call
    assert_equal true, result[:valid]
    assert_equal 16.0, result[:tip_amount]
    assert_equal 8.0, result[:tax_amount]
    assert_equal 104.0, result[:total]
    assert_equal 104.0, result[:per_person]
  end

  test "handles string inputs by converting to numeric" do
    result = Everyday::SplitBillCalculator.new(subtotal: "100", tip_percent: "15", tax_percent: "7", num_people: "3").call
    assert_equal true, result[:valid]
    assert_equal 15.0, result[:tip_amount]
    assert_equal 7.0, result[:tax_amount]
    assert_in_delta 40.67, result[:per_person], 0.01
  end

  # --- Validation errors ---

  test "error when subtotal is zero" do
    result = Everyday::SplitBillCalculator.new(subtotal: 0, tip_percent: 18, tax_percent: 8, num_people: 2).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Subtotal must be greater than zero"
  end

  test "error when tip percent is negative" do
    result = Everyday::SplitBillCalculator.new(subtotal: 50, tip_percent: -5, tax_percent: 8, num_people: 2).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Tip percent cannot be negative"
  end

  test "error when tax percent is negative" do
    result = Everyday::SplitBillCalculator.new(subtotal: 50, tip_percent: 18, tax_percent: -3, num_people: 2).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Tax percent cannot be negative"
  end

  test "error when num_people is zero" do
    result = Everyday::SplitBillCalculator.new(subtotal: 50, tip_percent: 18, tax_percent: 8, num_people: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Number of people must be at least 1"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::SplitBillCalculator.new(subtotal: 50, tip_percent: 18, tax_percent: 8, num_people: 2)
    assert_equal [], calc.errors
  end
end
