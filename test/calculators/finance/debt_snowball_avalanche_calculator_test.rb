require "test_helper"

class Finance::DebtSnowballAvalancheCalculatorTest < ActiveSupport::TestCase
  test "happy path: avalanche saves more interest than snowball" do
    debts = [
      { name: "Credit Card", balance: 5_000, rate: 18, minimum_payment: 100 },
      { name: "Car Loan", balance: 15_000, rate: 6, minimum_payment: 300 },
      { name: "Student Loan", balance: 10_000, rate: 5, minimum_payment: 200 }
    ]
    calc = Finance::DebtSnowballAvalancheCalculator.new(debts: debts, extra_payment: 200)
    result = calc.call

    assert result[:valid]
    assert result[:snowball][:total_months] > 0
    assert result[:avalanche][:total_months] > 0
    assert result[:avalanche][:total_interest] <= result[:snowball][:total_interest]
    assert_equal "avalanche", result[:recommended]
  end

  test "single debt: both strategies give same result" do
    debts = [
      { name: "Credit Card", balance: 5_000, rate: 18, minimum_payment: 200 }
    ]
    calc = Finance::DebtSnowballAvalancheCalculator.new(debts: debts, extra_payment: 100)
    result = calc.call

    assert result[:valid]
    assert_equal result[:snowball][:total_months], result[:avalanche][:total_months]
    assert_in_delta result[:snowball][:total_interest], result[:avalanche][:total_interest], 0.01
  end

  test "no extra payment still works" do
    debts = [
      { name: "Debt A", balance: 1_000, rate: 10, minimum_payment: 100 },
      { name: "Debt B", balance: 2_000, rate: 15, minimum_payment: 100 }
    ]
    calc = Finance::DebtSnowballAvalancheCalculator.new(debts: debts, extra_payment: 0)
    result = calc.call

    assert result[:valid]
    assert result[:snowball][:total_months] > 0
  end

  test "empty debts returns error" do
    calc = Finance::DebtSnowballAvalancheCalculator.new(debts: [], extra_payment: 100)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "At least one debt is required"
  end

  test "negative extra payment returns error" do
    debts = [{ name: "Debt", balance: 1_000, rate: 10, minimum_payment: 50 }]
    calc = Finance::DebtSnowballAvalancheCalculator.new(debts: debts, extra_payment: -100)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Extra payment cannot be negative"
  end

  test "debt with zero balance returns error" do
    debts = [{ name: "Debt", balance: 0, rate: 10, minimum_payment: 50 }]
    calc = Finance::DebtSnowballAvalancheCalculator.new(debts: debts, extra_payment: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Debt 1 balance must be positive"
  end

  test "debt with zero minimum payment returns error" do
    debts = [{ name: "Debt", balance: 1_000, rate: 10, minimum_payment: 0 }]
    calc = Finance::DebtSnowballAvalancheCalculator.new(debts: debts, extra_payment: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Debt 1 minimum payment must be positive"
  end

  test "zero interest debts still pay off" do
    debts = [
      { name: "Debt A", balance: 1_000, rate: 0, minimum_payment: 100 },
      { name: "Debt B", balance: 2_000, rate: 0, minimum_payment: 200 }
    ]
    calc = Finance::DebtSnowballAvalancheCalculator.new(debts: debts, extra_payment: 0)
    result = calc.call

    assert result[:valid]
    assert_in_delta 0, result[:snowball][:total_interest], 0.01
    assert_in_delta 0, result[:avalanche][:total_interest], 0.01
  end

  test "interest saved by avalanche is calculated correctly" do
    debts = [
      { name: "High Rate", balance: 3_000, rate: 20, minimum_payment: 100 },
      { name: "Low Rate", balance: 1_000, rate: 5, minimum_payment: 50 }
    ]
    calc = Finance::DebtSnowballAvalancheCalculator.new(debts: debts, extra_payment: 50)
    result = calc.call

    assert result[:valid]
    expected_saved = result[:snowball][:total_interest] - result[:avalanche][:total_interest]
    assert_in_delta expected_saved, result[:interest_saved_by_avalanche], 0.01
  end
end
