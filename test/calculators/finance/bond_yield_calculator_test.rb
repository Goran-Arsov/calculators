require "test_helper"

class Finance::BondYieldCalculatorTest < ActiveSupport::TestCase
  test "happy path: discount bond" do
    calc = Finance::BondYieldCalculator.new(
      face_value: 1_000, coupon_rate: 5,
      market_price: 950, years_to_maturity: 10
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 5.2632, result[:current_yield], 0.01
    assert result[:yield_to_maturity] > result[:current_yield]
    assert_equal 50.0, result[:annual_coupon]
    assert_equal 25.0, result[:coupon_payment]
    assert result[:is_discount]
    refute result[:is_premium]
  end

  test "happy path: premium bond" do
    calc = Finance::BondYieldCalculator.new(
      face_value: 1_000, coupon_rate: 8,
      market_price: 1_100, years_to_maturity: 10
    )
    result = calc.call

    assert result[:valid]
    assert result[:yield_to_maturity] < result[:current_yield]
    assert result[:is_premium]
    refute result[:is_discount]
  end

  test "par bond has current yield equal to coupon rate" do
    calc = Finance::BondYieldCalculator.new(
      face_value: 1_000, coupon_rate: 5,
      market_price: 1_000, years_to_maturity: 10
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 5.0, result[:current_yield], 0.01
    assert_in_delta 5.0, result[:yield_to_maturity], 0.1
  end

  test "annual payment frequency" do
    calc = Finance::BondYieldCalculator.new(
      face_value: 1_000, coupon_rate: 6,
      market_price: 980, years_to_maturity: 5,
      payments_per_year: 1
    )
    result = calc.call

    assert result[:valid]
    assert_equal 60.0, result[:annual_coupon]
    assert_equal 60.0, result[:coupon_payment]
  end

  test "zero coupon rate" do
    calc = Finance::BondYieldCalculator.new(
      face_value: 1_000, coupon_rate: 0,
      market_price: 800, years_to_maturity: 10
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0, result[:current_yield], 0.01
    assert result[:yield_to_maturity] > 0
  end

  test "negative face value returns error" do
    calc = Finance::BondYieldCalculator.new(
      face_value: -1_000, coupon_rate: 5,
      market_price: 950, years_to_maturity: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Face value must be positive"
  end

  test "zero market price returns error" do
    calc = Finance::BondYieldCalculator.new(
      face_value: 1_000, coupon_rate: 5,
      market_price: 0, years_to_maturity: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Market price must be positive"
  end

  test "zero years to maturity returns error" do
    calc = Finance::BondYieldCalculator.new(
      face_value: 1_000, coupon_rate: 5,
      market_price: 950, years_to_maturity: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Years to maturity must be positive"
  end

  test "string inputs are coerced" do
    calc = Finance::BondYieldCalculator.new(
      face_value: "1000", coupon_rate: "5",
      market_price: "950", years_to_maturity: "10"
    )
    result = calc.call

    assert result[:valid]
    assert result[:yield_to_maturity] > 0
  end
end
