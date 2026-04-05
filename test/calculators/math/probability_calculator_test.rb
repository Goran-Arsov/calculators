require "test_helper"

class Math::ProbabilityCalculatorTest < ActiveSupport::TestCase
  # --- Basic probability ---

  test "coin flip probability" do
    result = Math::ProbabilityCalculator.new(favorable: 1, total: 2).call
    assert result[:valid]
    assert_in_delta 0.5, result[:probability], 0.0001
    assert_in_delta 50.0, result[:percentage], 0.01
  end

  test "die roll probability for one face" do
    result = Math::ProbabilityCalculator.new(favorable: 1, total: 6).call
    assert result[:valid]
    assert_in_delta(1.0 / 6, result[:probability], 0.0001)
    assert_in_delta(100.0 / 6, result[:percentage], 0.01)
  end

  test "certain event has probability 1" do
    result = Math::ProbabilityCalculator.new(favorable: 6, total: 6).call
    assert result[:valid]
    assert_in_delta 1.0, result[:probability], 0.0001
    assert_in_delta 0.0, result[:complementary], 0.0001
  end

  # --- Complementary probability ---

  test "complementary probability of coin flip" do
    result = Math::ProbabilityCalculator.new(favorable: 1, total: 2).call
    assert result[:valid]
    assert_in_delta 0.5, result[:complementary], 0.0001
    assert_in_delta 50.0, result[:complementary_percentage], 0.01
  end

  # --- Odds ---

  test "odds for rolling a 6 on a die" do
    result = Math::ProbabilityCalculator.new(favorable: 1, total: 6).call
    assert result[:valid]
    assert_in_delta 0.2, result[:odds_for], 0.0001
    assert_in_delta 5.0, result[:odds_against], 0.0001
    assert_equal "1:5", result[:odds_ratio]
  end

  test "odds for drawing an ace from deck" do
    result = Math::ProbabilityCalculator.new(favorable: 4, total: 52).call
    assert result[:valid]
    assert_in_delta(4.0 / 48, result[:odds_for], 0.0001)
    assert_in_delta(48.0 / 4, result[:odds_against], 0.0001)
    assert_equal "4:48", result[:odds_ratio]
  end

  # --- Validation ---

  test "error when total is zero" do
    result = Math::ProbabilityCalculator.new(favorable: 1, total: 0).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Total") }
  end

  test "error when favorable exceeds total" do
    result = Math::ProbabilityCalculator.new(favorable: 10, total: 5).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("exceed") }
  end

  test "error when favorable is negative" do
    result = Math::ProbabilityCalculator.new(favorable: -1, total: 6).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("negative") }
  end

  test "error when favorable is zero" do
    result = Math::ProbabilityCalculator.new(favorable: 0, total: 6).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("greater than zero") }
  end

  # --- Edge cases ---

  test "large numbers" do
    result = Math::ProbabilityCalculator.new(favorable: 500_000, total: 1_000_000).call
    assert result[:valid]
    assert_in_delta 0.5, result[:probability], 0.0001
  end

  test "string coercion" do
    result = Math::ProbabilityCalculator.new(favorable: "3", total: "12").call
    assert result[:valid]
    assert_in_delta 0.25, result[:probability], 0.0001
  end

  test "errors accessor returns empty array before call" do
    calc = Math::ProbabilityCalculator.new(favorable: 1, total: 6)
    assert_equal [], calc.errors
  end
end
