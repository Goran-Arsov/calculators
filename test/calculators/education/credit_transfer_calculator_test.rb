require "test_helper"

class Education::CreditTransferCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates transfer analysis correctly" do
    calc = Education::CreditTransferCalculator.new(
      total_credits_earned: 60, transferable_credits: 48,
      degree_credits_required: 120, cost_per_credit_old: 150,
      cost_per_credit_new: 350, credits_per_semester: 15
    )
    result = calc.call

    assert result[:valid]
    assert_equal 12, result[:credits_lost]
    assert_in_delta 80.0, result[:transfer_rate], 0.1
    assert_equal 72, result[:remaining_credits]
    assert_equal 5, result[:remaining_semesters]
    assert_equal 25_200.0, result[:cost_of_remaining]
    assert_equal 42_000.0, result[:cost_if_no_transfer]
    assert_equal 16_800.0, result[:cost_savings]
    assert_equal 3, result[:time_saved_semesters]
    assert_equal 1_800.0, result[:value_of_lost_credits]
  end

  # --- All credits transfer ---

  test "all credits transferring gives maximum savings" do
    calc = Education::CreditTransferCalculator.new(
      total_credits_earned: 60, transferable_credits: 60,
      degree_credits_required: 120, cost_per_credit_new: 300, credits_per_semester: 15
    )
    result = calc.call

    assert result[:valid]
    assert_equal 0, result[:credits_lost]
    assert_in_delta 100.0, result[:transfer_rate], 0.1
    assert_equal 60, result[:remaining_credits]
  end

  # --- No credits transfer ---

  test "no credits transferring shows full cost" do
    calc = Education::CreditTransferCalculator.new(
      total_credits_earned: 60, transferable_credits: 0,
      degree_credits_required: 120, cost_per_credit_new: 300, credits_per_semester: 15
    )
    result = calc.call

    assert result[:valid]
    assert_equal 60, result[:credits_lost]
    assert_in_delta 0.0, result[:transfer_rate], 0.1
    assert_equal 120, result[:remaining_credits]
    assert_equal 0.0, result[:cost_savings]
  end

  # --- Credits exceed requirements ---

  test "transferable credits exceeding requirement shows zero remaining" do
    calc = Education::CreditTransferCalculator.new(
      total_credits_earned: 130, transferable_credits: 125,
      degree_credits_required: 120, cost_per_credit_new: 300, credits_per_semester: 15
    )
    result = calc.call

    assert result[:valid]
    assert_equal 0, result[:remaining_credits]
    assert_equal 0, result[:remaining_semesters]
  end

  # --- Remaining time calculation ---

  test "calculates remaining semesters and years" do
    calc = Education::CreditTransferCalculator.new(
      total_credits_earned: 30, transferable_credits: 30,
      degree_credits_required: 120, cost_per_credit_new: 300, credits_per_semester: 15
    )
    result = calc.call

    assert result[:valid]
    assert_equal 90, result[:remaining_credits]
    assert_equal 6, result[:remaining_semesters]
    assert_equal 3, result[:remaining_years]
  end

  # --- Validation ---

  test "zero total credits returns error" do
    calc = Education::CreditTransferCalculator.new(
      total_credits_earned: 0, transferable_credits: 0,
      cost_per_credit_new: 300
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Total credits earned must be positive"
  end

  test "transferable exceeding total returns error" do
    calc = Education::CreditTransferCalculator.new(
      total_credits_earned: 30, transferable_credits: 40,
      cost_per_credit_new: 300
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Transferable credits cannot exceed total credits earned"
  end

  test "zero cost per credit at new school returns error" do
    calc = Education::CreditTransferCalculator.new(
      total_credits_earned: 60, transferable_credits: 48,
      cost_per_credit_new: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Cost per credit at new school must be positive"
  end

  test "negative transferable credits returns error" do
    calc = Education::CreditTransferCalculator.new(
      total_credits_earned: 60, transferable_credits: -5,
      cost_per_credit_new: 300
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Transferable credits cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    calc = Education::CreditTransferCalculator.new(
      total_credits_earned: "60", transferable_credits: "48",
      cost_per_credit_new: "350"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 12, result[:credits_lost]
  end
end
