require "test_helper"

class Everyday::DiscountCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "price=100, discount=25% → sale_price=75, savings=25" do
    result = Everyday::DiscountCalculator.new(original_price: 100, discount_percent: 25).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 75.0, result[:sale_price]
    assert_equal 25.0, result[:savings]
    assert_equal 25.0, result[:discount_amount]
  end

  test "50% discount" do
    result = Everyday::DiscountCalculator.new(original_price: 200, discount_percent: 50).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 100.0, result[:sale_price]
    assert_equal 100.0, result[:savings]
  end

  test "0% discount returns original price" do
    result = Everyday::DiscountCalculator.new(original_price: 80, discount_percent: 0).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 80.0, result[:sale_price]
    assert_equal 0.0, result[:savings]
  end

  test "100% discount returns zero" do
    result = Everyday::DiscountCalculator.new(original_price: 50, discount_percent: 100).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0.0, result[:sale_price]
    assert_equal 50.0, result[:savings]
  end

  # --- Validation errors ---

  test "error when original price is zero" do
    result = Everyday::DiscountCalculator.new(original_price: 0, discount_percent: 25).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Original price must be greater than zero"
  end

  test "error when discount percent is negative" do
    result = Everyday::DiscountCalculator.new(original_price: 100, discount_percent: -10).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Discount percent must be between 0 and 100"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::DiscountCalculator.new(original_price: 100, discount_percent: 25)
    assert_equal [], calc.errors
  end
end
