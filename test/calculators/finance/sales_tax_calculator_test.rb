require "test_helper"

class Finance::SalesTaxCalculatorTest < ActiveSupport::TestCase
  test "happy path: standard sales tax" do
    calc = Finance::SalesTaxCalculator.new(subtotal: 100, tax_rate: 8.25)
    result = calc.call

    assert result[:valid]
    assert_in_delta 8.25, result[:tax_amount], 0.01
    assert_in_delta 108.25, result[:total], 0.01
    assert_in_delta 8.25, result[:tax_rate], 0.01
  end

  test "zero tax rate means no tax" do
    calc = Finance::SalesTaxCalculator.new(subtotal: 250, tax_rate: 0)
    result = calc.call

    assert result[:valid]
    assert_in_delta 0, result[:tax_amount], 0.01
    assert_in_delta 250, result[:total], 0.01
  end

  test "large purchase" do
    calc = Finance::SalesTaxCalculator.new(subtotal: 25_000, tax_rate: 9.5)
    result = calc.call

    assert result[:valid]
    assert_in_delta 2_375.0, result[:tax_amount], 0.01
    assert_in_delta 27_375.0, result[:total], 0.01
  end

  test "negative subtotal returns error" do
    calc = Finance::SalesTaxCalculator.new(subtotal: -100, tax_rate: 8)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Subtotal must be positive"
  end

  test "zero subtotal returns error" do
    calc = Finance::SalesTaxCalculator.new(subtotal: 0, tax_rate: 8)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Subtotal must be positive"
  end

  test "negative tax rate returns error" do
    calc = Finance::SalesTaxCalculator.new(subtotal: 100, tax_rate: -5)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Tax rate cannot be negative"
  end

  test "string inputs are coerced" do
    calc = Finance::SalesTaxCalculator.new(subtotal: "100", tax_rate: "8.25")
    result = calc.call

    assert result[:valid]
    assert_in_delta 8.25, result[:tax_amount], 0.01
  end

  test "very small tax rate" do
    calc = Finance::SalesTaxCalculator.new(subtotal: 100, tax_rate: 0.01)
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.01, result[:tax_amount], 0.01
  end
end
