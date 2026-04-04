require "test_helper"

class Finance::RentVsBuyCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic comparison returns total_rent and total_buy_cost" do
    result = Finance::RentVsBuyCalculator.new(
      monthly_rent: 1500,
      home_price: 300000,
      down_payment_pct: 20,
      interest_rate: 6,
      years: 30
    ).call
    assert result[:valid]
    assert result[:total_rent] > 0
    assert result[:total_buy_cost] > 0
    assert %w[buying renting].include?(result[:cheaper_option])
  end

  test "returns correct cheaper option" do
    result = Finance::RentVsBuyCalculator.new(
      monthly_rent: 500,
      home_price: 500000,
      down_payment_pct: 20,
      interest_rate: 7,
      years: 30
    ).call
    assert result[:valid]
    # With very low rent and expensive home, renting should be cheaper
    assert_equal "renting", result[:cheaper_option]
  end

  test "short time period comparison" do
    result = Finance::RentVsBuyCalculator.new(
      monthly_rent: 2000,
      home_price: 300000,
      down_payment_pct: 10,
      interest_rate: 5,
      years: 5
    ).call
    assert result[:valid]
    assert_equal 5, result[:years]
  end

  # --- Validation errors ---

  test "error when monthly rent is zero" do
    result = Finance::RentVsBuyCalculator.new(
      monthly_rent: 0,
      home_price: 300000,
      down_payment_pct: 20,
      interest_rate: 6,
      years: 30
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Monthly rent must be positive"
  end

  test "error when years is zero" do
    result = Finance::RentVsBuyCalculator.new(
      monthly_rent: 1500,
      home_price: 300000,
      down_payment_pct: 20,
      interest_rate: 6,
      years: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Years must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::RentVsBuyCalculator.new(
      monthly_rent: 1500,
      home_price: 300000,
      down_payment_pct: 20,
      interest_rate: 6,
      years: 30
    )
    assert_equal [], calc.errors
  end
end
