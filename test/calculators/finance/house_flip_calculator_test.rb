require "test_helper"

class Finance::HouseFlipCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: profitable flip" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: 150_000, renovation_cost: 40_000,
      after_repair_value: 280_000, holding_months: 6,
      holding_cost_monthly: 1_500
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 3_000.0, result[:closing_costs_buy], 0.01    # 150k * 2%
    assert_in_delta 16_800.0, result[:closing_costs_sell], 0.01  # 280k * 6%
    assert_in_delta 9_000.0, result[:total_holding_costs], 0.01  # 1500 * 6
    assert result[:net_profit] > 0
    assert result[:roi] > 0
  end

  test "happy path: 70% rule max purchase" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: 150_000, renovation_cost: 50_000,
      after_repair_value: 300_000
    )
    result = calc.call

    assert result[:valid]
    # 300000 * 0.70 - 50000 = 160000
    assert_in_delta 160_000.0, result[:max_purchase_70_rule], 0.01
  end

  test "happy path: zero holding costs" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: 100_000, renovation_cost: 30_000,
      after_repair_value: 200_000, holding_cost_monthly: 0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:total_holding_costs], 0.01
  end

  # --- Loss scenario ---

  test "negative profit when ARV is too low" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: 200_000, renovation_cost: 50_000,
      after_repair_value: 220_000, holding_months: 6,
      holding_cost_monthly: 2_000
    )
    result = calc.call

    assert result[:valid]
    assert result[:net_profit] < 0
    assert result[:roi] < 0
  end

  # --- Annualized ROI ---

  test "annualized ROI scales for holding period" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: 100_000, renovation_cost: 20_000,
      after_repair_value: 200_000, holding_months: 3
    )
    result = calc.call

    assert result[:valid]
    # Annualized should be 4x the 3-month ROI
    assert_in_delta result[:roi] * 4, result[:annualized_roi], 0.1
  end

  # --- Zero / Negative values ---

  test "zero purchase price returns error" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: 0, renovation_cost: 40_000, after_repair_value: 280_000
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Purchase price must be positive"
  end

  test "zero ARV returns error" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: 150_000, renovation_cost: 40_000, after_repair_value: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "After repair value must be positive"
  end

  test "negative renovation cost returns error" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: 150_000, renovation_cost: -10_000, after_repair_value: 280_000
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Renovation cost cannot be negative"
  end

  test "zero holding months returns error" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: 150_000, renovation_cost: 40_000,
      after_repair_value: 280_000, holding_months: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Holding months must be positive"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: "150000", renovation_cost: "40000",
      after_repair_value: "280000", holding_months: "6",
      holding_cost_monthly: "1500"
    )
    result = calc.call

    assert result[:valid]
    assert result[:net_profit] > 0
  end

  # --- Large numbers ---

  test "very large property values still compute" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: 5_000_000, renovation_cost: 1_000_000,
      after_repair_value: 10_000_000
    )
    result = calc.call

    assert result[:valid]
    assert result[:net_profit] > 0
  end

  # --- Custom closing costs ---

  test "custom closing cost percentages are respected" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: 100_000, renovation_cost: 0,
      after_repair_value: 200_000,
      closing_cost_buy_percent: 3, closing_cost_sell_percent: 8
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 3_000.0, result[:closing_costs_buy], 0.01
    assert_in_delta 16_000.0, result[:closing_costs_sell], 0.01
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::HouseFlipCalculator.new(
      purchase_price: -1, renovation_cost: -1,
      after_repair_value: -1, holding_months: 0,
      holding_cost_monthly: -1
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 4
  end
end
