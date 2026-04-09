require "test_helper"

class Finance::InheritanceTaxCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: no state tax when state is none" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 1_000_000, state: "none", relationship: "other")
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:estimated_tax], 0.01
    assert_in_delta 0.0, result[:taxable_amount], 0.01
    assert_in_delta 1_000_000.0, result[:exempt_amount], 0.01
  end

  test "happy path: spouse is exempt in all states" do
    %w[iowa kentucky maryland nebraska new_jersey pennsylvania].each do |state|
      calc = Finance::InheritanceTaxCalculator.new(estate_value: 5_000_000, state: state, relationship: "spouse")
      result = calc.call

      assert result[:valid], "Expected valid for state=#{state}"
      assert_in_delta 0.0, result[:estimated_tax], 0.01, "Spouse should be exempt in #{state}"
      assert_in_delta 0.0, result[:taxable_amount], 0.01
    end
  end

  test "happy path: pennsylvania child at 4.5%" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 500_000, state: "pennsylvania", relationship: "child")
    result = calc.call

    assert result[:valid]
    expected_tax = 500_000 * 0.045
    assert_in_delta expected_tax, result[:estimated_tax], 0.01
    assert_in_delta 500_000.0, result[:taxable_amount], 0.01
  end

  test "happy path: pennsylvania sibling at 12%" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 200_000, state: "pennsylvania", relationship: "sibling")
    result = calc.call

    assert result[:valid]
    expected_tax = 200_000 * 0.12
    assert_in_delta expected_tax, result[:estimated_tax], 0.01
  end

  test "happy path: maryland flat 10% for other" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 300_000, state: "maryland", relationship: "other")
    result = calc.call

    assert result[:valid]
    expected_tax = 300_000 * 0.10
    assert_in_delta expected_tax, result[:estimated_tax], 0.01
    assert_in_delta 10.0, result[:effective_rate], 0.01
  end

  test "happy path: nebraska child with exemption" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 200_000, state: "nebraska", relationship: "child")
    result = calc.call

    assert result[:valid]
    taxable = 200_000 - 100_000
    expected_tax = taxable * 0.01
    assert_in_delta expected_tax, result[:estimated_tax], 0.01
    assert_in_delta 100_000.0, result[:exempt_amount], 0.01
  end

  test "happy path: nebraska child below exemption owes nothing" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 50_000, state: "nebraska", relationship: "child")
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:estimated_tax], 0.01
    assert_in_delta 0.0, result[:taxable_amount], 0.01
  end

  test "happy path: kentucky sibling with marginal brackets" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 25_000, state: "kentucky", relationship: "sibling")
    result = calc.call

    assert result[:valid]
    # Exemption: 1000, taxable: 24000
    # First 10000 at 4%, next 10000 at 5%, next 4000 at 6%
    expected_tax = (10_000 * 0.04) + (10_000 * 0.05) + (4_000 * 0.06)
    assert_in_delta expected_tax, result[:estimated_tax], 0.01
  end

  test "happy path: new_jersey sibling with exemption" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 100_000, state: "new_jersey", relationship: "sibling")
    result = calc.call

    assert result[:valid]
    taxable = 100_000 - 25_000
    expected_tax = taxable * 0.11
    assert_in_delta expected_tax, result[:estimated_tax], 0.01
  end

  test "happy path: iowa child is exempt" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 500_000, state: "iowa", relationship: "child")
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:estimated_tax], 0.01
  end

  # --- Effective rate ---

  test "effective rate calculated correctly" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 500_000, state: "pennsylvania", relationship: "other")
    result = calc.call

    assert result[:valid]
    expected_rate = (500_000 * 0.15) / 500_000 * 100
    assert_in_delta expected_rate, result[:effective_rate], 0.01
  end

  # --- Negative / zero values ---

  test "zero estate value returns error" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 0, state: "maryland", relationship: "other")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Estate value must be positive"
  end

  test "negative estate value returns error" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: -100_000, state: "maryland", relationship: "other")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Estate value must be positive"
  end

  test "invalid state returns error" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 100_000, state: "california", relationship: "other")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid state"
  end

  test "invalid relationship returns error" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 100_000, state: "maryland", relationship: "friend")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid relationship"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: "500000", state: "pennsylvania", relationship: "child")
    result = calc.call

    assert result[:valid]
    assert result[:estimated_tax] > 0
  end

  # --- Large numbers ---

  test "very large estate still computes" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: 100_000_000, state: "pennsylvania", relationship: "other")
    result = calc.call

    assert result[:valid]
    assert result[:estimated_tax] > 0
    assert_in_delta 15.0, result[:effective_rate], 0.01
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::InheritanceTaxCalculator.new(estate_value: -1, state: "bogus", relationship: "bogus")
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 3
  end
end
