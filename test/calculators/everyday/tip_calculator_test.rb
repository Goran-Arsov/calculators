require "test_helper"

class Everyday::TipCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "bill=50, tip=20%, split=2 → tip=10, total=60, per_person=30" do
    result = Everyday::TipCalculator.new(bill_amount: 50, tip_percent: 20, split: 2).call
    assert_nil result[:errors]
    assert_equal 10.0, result[:tip_amount]
    assert_equal 60.0, result[:total]
    assert_equal 30.0, result[:per_person]
  end

  test "no split (1 person)" do
    result = Everyday::TipCalculator.new(bill_amount: 100, tip_percent: 15, split: 1).call
    assert_nil result[:errors]
    assert_equal 15.0, result[:tip_amount]
    assert_equal 115.0, result[:total]
    assert_equal 115.0, result[:per_person]
  end

  test "zero tip" do
    result = Everyday::TipCalculator.new(bill_amount: 50, tip_percent: 0, split: 1).call
    assert_nil result[:errors]
    assert_equal 0.0, result[:tip_amount]
    assert_equal 50.0, result[:total]
  end

  test "split among 4 people" do
    result = Everyday::TipCalculator.new(bill_amount: 100, tip_percent: 20, split: 4).call
    assert_nil result[:errors]
    assert_equal 30.0, result[:per_person]
  end

  # --- Validation errors ---

  test "error when bill amount is zero" do
    result = Everyday::TipCalculator.new(bill_amount: 0, tip_percent: 20, split: 2).call
    assert result[:errors].any?
    assert_includes result[:errors], "Bill amount must be greater than zero"
  end

  test "error when tip percent is negative" do
    result = Everyday::TipCalculator.new(bill_amount: 50, tip_percent: -10, split: 1).call
    assert result[:errors].any?
    assert_includes result[:errors], "Tip percent cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::TipCalculator.new(bill_amount: 50, tip_percent: 20, split: 2)
    assert_equal [], calc.errors
  end
end
