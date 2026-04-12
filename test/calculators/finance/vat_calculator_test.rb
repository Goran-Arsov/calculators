require "test_helper"

class Finance::VatCalculatorTest < ActiveSupport::TestCase
  test "add VAT: standard 20% rate" do
    calc = Finance::VatCalculator.new(amount: 100, vat_rate: 20, mode: "add")
    result = calc.call

    assert result[:valid]
    assert_in_delta 100, result[:net_price], 0.01
    assert_in_delta 20, result[:vat_amount], 0.01
    assert_in_delta 120, result[:gross_price], 0.01
    assert_equal "add", result[:mode]
  end

  test "remove VAT: extract from gross price" do
    calc = Finance::VatCalculator.new(amount: 120, vat_rate: 20, mode: "remove")
    result = calc.call

    assert result[:valid]
    assert_in_delta 100, result[:net_price], 0.01
    assert_in_delta 20, result[:vat_amount], 0.01
    assert_in_delta 120, result[:gross_price], 0.01
    assert_equal "remove", result[:mode]
  end

  test "zero VAT rate" do
    calc = Finance::VatCalculator.new(amount: 100, vat_rate: 0, mode: "add")
    result = calc.call

    assert result[:valid]
    assert_in_delta 0, result[:vat_amount], 0.01
    assert_in_delta 100, result[:gross_price], 0.01
  end

  test "high VAT rate (27% Hungary)" do
    calc = Finance::VatCalculator.new(amount: 100, vat_rate: 27, mode: "add")
    result = calc.call

    assert result[:valid]
    assert_in_delta 27, result[:vat_amount], 0.01
    assert_in_delta 127, result[:gross_price], 0.01
  end

  test "negative amount returns error" do
    calc = Finance::VatCalculator.new(amount: -100, vat_rate: 20, mode: "add")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Amount must be positive"
  end

  test "negative VAT rate returns error" do
    calc = Finance::VatCalculator.new(amount: 100, vat_rate: -5, mode: "add")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "VAT rate cannot be negative"
  end

  test "invalid mode returns error" do
    calc = Finance::VatCalculator.new(amount: 100, vat_rate: 20, mode: "calculate")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Mode must be 'add' or 'remove'"
  end

  test "round trip: add then remove gives original" do
    add_result = Finance::VatCalculator.new(amount: 99.99, vat_rate: 21, mode: "add").call
    remove_result = Finance::VatCalculator.new(amount: add_result[:gross_price], vat_rate: 21, mode: "remove").call

    assert_in_delta 99.99, remove_result[:net_price], 0.02
  end

  test "string inputs are coerced" do
    calc = Finance::VatCalculator.new(amount: "100", vat_rate: "20", mode: "add")
    result = calc.call

    assert result[:valid]
    assert_in_delta 120, result[:gross_price], 0.01
  end
end
