require "test_helper"

class Health::BloodPressureCalculatorTest < ActiveSupport::TestCase
  # --- Normal blood pressure ---

  test "normal blood pressure 115/75" do
    result = Health::BloodPressureCalculator.new(systolic: 115, diastolic: 75).call
    assert result[:valid]
    assert_equal "Normal", result[:category]
    assert_equal "low", result[:risk_level]
    assert_equal 40, result[:pulse_pressure]
    assert_in_delta 88.3, result[:mean_arterial_pressure], 0.1
  end

  # --- Hypotension ---

  test "hypotension low systolic" do
    result = Health::BloodPressureCalculator.new(systolic: 85, diastolic: 55).call
    assert result[:valid]
    assert_equal "Hypotension", result[:category]
  end

  test "hypotension low diastolic" do
    result = Health::BloodPressureCalculator.new(systolic: 100, diastolic: 55).call
    assert result[:valid]
    assert_equal "Hypotension", result[:category]
  end

  # --- Elevated ---

  test "elevated blood pressure 125/75" do
    result = Health::BloodPressureCalculator.new(systolic: 125, diastolic: 75).call
    assert result[:valid]
    assert_equal "Elevated", result[:category]
    assert_equal "moderate", result[:risk_level]
  end

  # --- Stage 1 Hypertension ---

  test "stage 1 hypertension systolic 135/78" do
    result = Health::BloodPressureCalculator.new(systolic: 135, diastolic: 78).call
    assert result[:valid]
    assert_equal "High Blood Pressure Stage 1", result[:category]
    assert_equal "moderate", result[:risk_level]
  end

  test "stage 1 hypertension diastolic 125/85" do
    result = Health::BloodPressureCalculator.new(systolic: 125, diastolic: 85).call
    assert result[:valid]
    assert_equal "High Blood Pressure Stage 1", result[:category]
  end

  # --- Stage 2 Hypertension ---

  test "stage 2 hypertension systolic 155/85" do
    result = Health::BloodPressureCalculator.new(systolic: 155, diastolic: 85).call
    assert result[:valid]
    assert_equal "High Blood Pressure Stage 2", result[:category]
    assert_equal "high", result[:risk_level]
  end

  test "stage 2 hypertension diastolic 135/95" do
    result = Health::BloodPressureCalculator.new(systolic: 135, diastolic: 95).call
    assert result[:valid]
    assert_equal "High Blood Pressure Stage 2", result[:category]
  end

  # --- Hypertensive Crisis ---

  test "hypertensive crisis systolic 185/100" do
    result = Health::BloodPressureCalculator.new(systolic: 185, diastolic: 100).call
    assert result[:valid]
    assert_equal "Hypertensive Crisis", result[:category]
    assert_equal "critical", result[:risk_level]
  end

  test "hypertensive crisis diastolic 150/125" do
    result = Health::BloodPressureCalculator.new(systolic: 150, diastolic: 125).call
    assert result[:valid]
    assert_equal "Hypertensive Crisis", result[:category]
  end

  # --- Pulse pressure ---

  test "pulse pressure is systolic minus diastolic" do
    result = Health::BloodPressureCalculator.new(systolic: 120, diastolic: 80).call
    assert result[:valid]
    assert_equal 40, result[:pulse_pressure]
  end

  # --- Mean arterial pressure ---

  test "mean arterial pressure formula" do
    result = Health::BloodPressureCalculator.new(systolic: 120, diastolic: 80).call
    # MAP = 80 + (40/3) = 93.3
    assert_in_delta 93.3, result[:mean_arterial_pressure], 0.1
  end

  # --- Recommendation is present ---

  test "recommendation is a non-empty string" do
    result = Health::BloodPressureCalculator.new(systolic: 120, diastolic: 80).call
    assert result[:valid]
    assert result[:recommendation].is_a?(String)
    assert result[:recommendation].length > 0
  end

  # --- Validation ---

  test "zero systolic returns error" do
    result = Health::BloodPressureCalculator.new(systolic: 0, diastolic: 80).call
    refute result[:valid]
    assert_includes result[:errors], "Systolic pressure must be positive"
  end

  test "zero diastolic returns error" do
    result = Health::BloodPressureCalculator.new(systolic: 120, diastolic: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Diastolic pressure must be positive"
  end

  test "systolic out of range returns error" do
    result = Health::BloodPressureCalculator.new(systolic: 50, diastolic: 40).call
    refute result[:valid]
    assert_includes result[:errors], "Systolic pressure must be between 60 and 300 mmHg"
  end

  test "diastolic out of range returns error" do
    result = Health::BloodPressureCalculator.new(systolic: 120, diastolic: 25).call
    refute result[:valid]
    assert_includes result[:errors], "Diastolic pressure must be between 30 and 200 mmHg"
  end

  test "systolic less than diastolic returns error" do
    result = Health::BloodPressureCalculator.new(systolic: 70, diastolic: 80).call
    refute result[:valid]
    assert_includes result[:errors], "Systolic must be greater than diastolic"
  end

  test "multiple validation errors at once" do
    result = Health::BloodPressureCalculator.new(systolic: 0, diastolic: 0).call
    refute result[:valid]
    assert result[:errors].length >= 2
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Health::BloodPressureCalculator.new(systolic: "120", diastolic: "80").call
    assert result[:valid]
    assert_equal "Normal", result[:category]
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::BloodPressureCalculator.new(systolic: 120, diastolic: 80)
    assert_equal [], calc.errors
  end
end
