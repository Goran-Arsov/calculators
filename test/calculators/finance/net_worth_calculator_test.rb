require "test_helper"

class Finance::NetWorthCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: positive net worth" do
    calc = Finance::NetWorthCalculator.new(
      assets: { cash: 50_000, investments: 100_000, real_estate: 300_000, vehicles: 25_000, other_assets: 10_000 },
      liabilities: { mortgage: 200_000, student_loans: 35_000, auto_loans: 15_000, credit_cards: 5_000, other_liabilities: 2_000 }
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert_in_delta 485_000.00, result[:total_assets], 0.01
    assert_in_delta 257_000.00, result[:total_liabilities], 0.01
    assert_in_delta 228_000.00, result[:net_worth], 0.01
    assert_in_delta 1.89, result[:asset_to_debt_ratio], 0.01
  end

  test "happy path: negative net worth" do
    calc = Finance::NetWorthCalculator.new(
      assets: { cash: 5_000, investments: 0, real_estate: 0, vehicles: 10_000, other_assets: 0 },
      liabilities: { mortgage: 0, student_loans: 50_000, auto_loans: 12_000, credit_cards: 8_000, other_liabilities: 0 }
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 15_000.00, result[:total_assets], 0.01
    assert_in_delta 70_000.00, result[:total_liabilities], 0.01
    assert_in_delta(-55_000.00, result[:net_worth], 0.01)
  end

  # --- Zero liabilities ---

  test "no liabilities results in infinite asset-to-debt ratio" do
    calc = Finance::NetWorthCalculator.new(
      assets: { cash: 100_000, investments: 50_000 },
      liabilities: {}
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 150_000.00, result[:total_assets], 0.01
    assert_in_delta 0.00, result[:total_liabilities], 0.01
    assert_in_delta 150_000.00, result[:net_worth], 0.01
    assert_equal Float::INFINITY, result[:asset_to_debt_ratio]
  end

  # --- All zeroes ---

  test "all zeroes returns zero net worth" do
    calc = Finance::NetWorthCalculator.new(assets: {}, liabilities: {})
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.00, result[:total_assets], 0.01
    assert_in_delta 0.00, result[:total_liabilities], 0.01
    assert_in_delta 0.00, result[:net_worth], 0.01
  end

  # --- Negative values ---

  test "negative asset returns error" do
    calc = Finance::NetWorthCalculator.new(
      assets: { cash: -5_000 },
      liabilities: {}
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Cash cannot be negative"
  end

  test "negative liability returns error" do
    calc = Finance::NetWorthCalculator.new(
      assets: {},
      liabilities: { mortgage: -100_000 }
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Mortgage cannot be negative"
  end

  test "multiple negative values return multiple errors" do
    calc = Finance::NetWorthCalculator.new(
      assets: { cash: -1, investments: -2 },
      liabilities: { mortgage: -3 }
    )
    result = calc.call

    refute result[:valid]
    assert_equal 3, calc.errors.size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::NetWorthCalculator.new(
      assets: { cash: "50000", investments: "100000" },
      liabilities: { mortgage: "200000" }
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 150_000.00, result[:total_assets], 0.01
    assert_in_delta 200_000.00, result[:total_liabilities], 0.01
    assert_in_delta(-50_000.00, result[:net_worth], 0.01)
  end

  # --- Large numbers ---

  test "very large numbers still compute" do
    calc = Finance::NetWorthCalculator.new(
      assets: { cash: 500_000_000, real_estate: 1_000_000_000 },
      liabilities: { mortgage: 300_000_000 }
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_500_000_000.00, result[:total_assets], 0.01
    assert_in_delta 300_000_000.00, result[:total_liabilities], 0.01
    assert_in_delta 1_200_000_000.00, result[:net_worth], 0.01
  end

  # --- Missing keys default to zero ---

  test "missing asset keys default to zero" do
    calc = Finance::NetWorthCalculator.new(
      assets: { cash: 10_000 },
      liabilities: { mortgage: 5_000 }
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_000.00, result[:total_assets], 0.01
    assert_in_delta 5_000.00, result[:total_liabilities], 0.01
  end

  # --- Asset-to-debt ratio ---

  test "asset-to-debt ratio is calculated correctly" do
    calc = Finance::NetWorthCalculator.new(
      assets: { cash: 100_000 },
      liabilities: { credit_cards: 50_000 }
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 2.0, result[:asset_to_debt_ratio], 0.01
  end
end
