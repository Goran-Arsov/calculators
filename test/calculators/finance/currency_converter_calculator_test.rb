require "test_helper"

class Finance::CurrencyConverterCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: USD to EUR" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 1_000,
      from_currency: "USD",
      to_currency: "EUR"
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert_in_delta 920.00, result[:converted_amount], 0.01
    assert_in_delta 0.92, result[:exchange_rate], 0.0001
    assert_in_delta(1.0 / 0.92, result[:inverse_rate], 0.0001)
  end

  test "happy path: EUR to USD" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 1_000,
      from_currency: "EUR",
      to_currency: "USD"
    )
    result = calc.call

    assert result[:valid]
    # 1000 EUR / 0.92 (EUR per USD) = ~1086.96 USD
    expected = 1_000.0 / 0.92
    assert_in_delta expected, result[:converted_amount], 0.01
  end

  test "happy path: cross rate EUR to JPY" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 500,
      from_currency: "EUR",
      to_currency: "JPY"
    )
    result = calc.call

    assert result[:valid]
    # 500 EUR -> USD -> JPY
    # 500 / 0.92 * 149.5
    expected = (500.0 / 0.92) * 149.5
    assert_in_delta expected, result[:converted_amount], 0.5
  end

  test "happy path: same currency returns same amount" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 250,
      from_currency: "GBP",
      to_currency: "GBP"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 250.00, result[:converted_amount], 0.01
    assert_in_delta 1.0, result[:exchange_rate], 0.0001
    assert_in_delta 1.0, result[:inverse_rate], 0.0001
  end

  # --- All supported currencies ---

  test "all supported currencies are present" do
    expected_currencies = %w[USD EUR GBP JPY CAD AUD CHF CNY INR MXN BRL KRW SEK NOK NZD SGD HKD TRY ZAR AED]
    assert_equal expected_currencies.sort, Finance::CurrencyConverterCalculator::SUPPORTED_CURRENCIES.sort
  end

  # --- Validation errors ---

  test "zero amount returns error" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 0,
      from_currency: "USD",
      to_currency: "EUR"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Amount must be positive"
  end

  test "negative amount returns error" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: -100,
      from_currency: "USD",
      to_currency: "EUR"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Amount must be positive"
  end

  test "unsupported from currency returns error" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 100,
      from_currency: "XYZ",
      to_currency: "EUR"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Unsupported source currency: XYZ"
  end

  test "unsupported to currency returns error" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 100,
      from_currency: "USD",
      to_currency: "ABC"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Unsupported target currency: ABC"
  end

  test "multiple validation errors returned at once" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 0,
      from_currency: "XYZ",
      to_currency: "ABC"
    )
    result = calc.call

    refute result[:valid]
    assert_equal 3, calc.errors.size
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: "1000",
      from_currency: "usd",
      to_currency: "eur"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 920.00, result[:converted_amount], 0.01
  end

  # --- Large numbers ---

  test "very large amount still computes" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 1_000_000_000,
      from_currency: "USD",
      to_currency: "JPY"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 149_500_000_000.0, result[:converted_amount], 1_000.0
  end

  # --- Inverse relationship ---

  test "converting A to B and B to A are inverse" do
    calc_forward = Finance::CurrencyConverterCalculator.new(
      amount: 1,
      from_currency: "USD",
      to_currency: "GBP"
    )
    calc_inverse = Finance::CurrencyConverterCalculator.new(
      amount: 1,
      from_currency: "GBP",
      to_currency: "USD"
    )

    forward = calc_forward.call
    inverse = calc_inverse.call

    assert forward[:valid]
    assert inverse[:valid]
    # Forward exchange rate should be inverse of the reverse exchange rate
    assert_in_delta forward[:exchange_rate], inverse[:inverse_rate], 0.0001
    assert_in_delta forward[:inverse_rate], inverse[:exchange_rate], 0.0001
  end

  # --- Small amount ---

  test "small fractional amount" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 0.01,
      from_currency: "USD",
      to_currency: "KRW"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 13.30, result[:converted_amount], 0.01
  end

  # --- Output includes input currencies ---

  test "result includes from and to currency codes" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 100,
      from_currency: "CAD",
      to_currency: "AUD"
    )
    result = calc.call

    assert result[:valid]
    assert_equal "CAD", result[:from_currency]
    assert_equal "AUD", result[:to_currency]
    assert_in_delta 100.0, result[:amount], 0.01
  end

  # --- Rates last updated ---

  test "RATES_LAST_UPDATED constant is defined" do
    assert_equal "2026-04-05", Finance::CurrencyConverterCalculator::RATES_LAST_UPDATED
  end

  test "result includes rates_last_updated" do
    calc = Finance::CurrencyConverterCalculator.new(
      amount: 100,
      from_currency: "USD",
      to_currency: "EUR"
    )
    result = calc.call

    assert result[:valid]
    assert_equal "2026-04-05", result[:rates_last_updated]
  end
end
