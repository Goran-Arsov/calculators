require "test_helper"

class Health::BmiCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: metric ---

  test "happy path metric: normal weight" do
    # 70 kg, 175 cm => BMI = 70 / (1.75^2) = 22.9
    result = Health::BmiCalculator.new(weight: 70, height: 175, unit_system: "metric").call
    assert result[:valid]
    assert_in_delta 22.9, result[:bmi], 0.1
    assert_equal "Normal weight", result[:category]
  end

  test "metric: underweight" do
    # 45 kg, 175 cm => BMI = 45 / (1.75^2) = 14.7
    result = Health::BmiCalculator.new(weight: 45, height: 175, unit_system: "metric").call
    assert result[:valid]
    assert_in_delta 14.7, result[:bmi], 0.1
    assert_equal "Underweight", result[:category]
  end

  test "metric: overweight" do
    # 85 kg, 175 cm => BMI = 85 / (1.75^2) = 27.8
    result = Health::BmiCalculator.new(weight: 85, height: 175, unit_system: "metric").call
    assert result[:valid]
    assert_in_delta 27.8, result[:bmi], 0.1
    assert_equal "Overweight", result[:category]
  end

  test "metric: obese" do
    # 110 kg, 175 cm => BMI = 110 / (1.75^2) = 35.9
    result = Health::BmiCalculator.new(weight: 110, height: 175, unit_system: "metric").call
    assert result[:valid]
    assert_in_delta 35.9, result[:bmi], 0.1
    assert_equal "Obese", result[:category]
  end

  test "metric: boundary at 18.5 is normal weight" do
    # height_m = 1.75, weight = 18.5 * 1.75^2 = 56.65625
    height_m = 1.75
    weight = 18.5 * height_m**2
    result = Health::BmiCalculator.new(weight: weight, height: 175, unit_system: "metric").call
    assert result[:valid]
    assert_in_delta 18.5, result[:bmi], 0.1
    assert_equal "Normal weight", result[:category]
  end

  test "metric: boundary at 25 is overweight" do
    height_m = 1.75
    weight = 25.0 * height_m**2
    result = Health::BmiCalculator.new(weight: weight, height: 175, unit_system: "metric").call
    assert result[:valid]
    assert_in_delta 25.0, result[:bmi], 0.1
    assert_equal "Overweight", result[:category]
  end

  test "metric: boundary at 30 is obese" do
    height_m = 1.75
    weight = 30.0 * height_m**2
    result = Health::BmiCalculator.new(weight: weight, height: 175, unit_system: "metric").call
    assert result[:valid]
    assert_in_delta 30.0, result[:bmi], 0.1
    assert_equal "Obese", result[:category]
  end

  # --- Happy path: imperial ---

  test "happy path imperial: normal weight" do
    # 154 lbs, 69 inches => BMI = (154 / 69^2) * 703 = 22.7
    result = Health::BmiCalculator.new(weight: 154, height: 69, unit_system: "imperial").call
    assert result[:valid]
    assert_in_delta 22.7, result[:bmi], 0.2
    assert_equal "Normal weight", result[:category]
  end

  test "imperial: obese" do
    # 250 lbs, 65 inches => BMI = (250 / 65^2) * 703 = 41.6
    result = Health::BmiCalculator.new(weight: 250, height: 65, unit_system: "imperial").call
    assert result[:valid]
    assert_in_delta 41.6, result[:bmi], 0.2
    assert_equal "Obese", result[:category]
  end

  test "imperial: underweight" do
    # 100 lbs, 70 inches => BMI = (100 / 70^2) * 703 = 14.3
    result = Health::BmiCalculator.new(weight: 100, height: 70, unit_system: "imperial").call
    assert result[:valid]
    assert_in_delta 14.3, result[:bmi], 0.2
    assert_equal "Underweight", result[:category]
  end

  # --- Healthy weight range ---

  test "metric: healthy weight range is returned" do
    result = Health::BmiCalculator.new(weight: 70, height: 175, unit_system: "metric").call
    assert result[:valid]
    height_m = 1.75
    expected_min = (18.5 * height_m**2).round(1)
    expected_max = (24.9 * height_m**2).round(1)
    assert_in_delta expected_min, result[:healthy_min], 0.2
    assert_in_delta expected_max, result[:healthy_max], 0.2
  end

  test "imperial: healthy weight range is returned in lbs" do
    result = Health::BmiCalculator.new(weight: 154, height: 69, unit_system: "imperial").call
    assert result[:valid]
    height_m = 69 * 0.0254
    expected_min = (18.5 * height_m**2 * 2.205).round(1)
    expected_max = (24.9 * height_m**2 * 2.205).round(1)
    assert_in_delta expected_min, result[:healthy_min], 0.5
    assert_in_delta expected_max, result[:healthy_max], 0.5
  end

  # --- Default unit system ---

  test "default unit system is metric" do
    result = Health::BmiCalculator.new(weight: 70, height: 175).call
    assert result[:valid]
    # Metric BMI formula: 70/(1.75^2) = 22.9
    assert_in_delta 22.9, result[:bmi], 0.1
  end

  # --- Validation: zero values ---

  test "zero weight returns error" do
    result = Health::BmiCalculator.new(weight: 0, height: 175, unit_system: "metric").call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "zero height returns error" do
    result = Health::BmiCalculator.new(weight: 70, height: 0, unit_system: "metric").call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  # --- Validation: negative values ---

  test "negative weight returns error" do
    result = Health::BmiCalculator.new(weight: -70, height: 175, unit_system: "metric").call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "negative height returns error" do
    result = Health::BmiCalculator.new(weight: 70, height: -175, unit_system: "metric").call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  test "both weight and height negative returns both errors" do
    result = Health::BmiCalculator.new(weight: -70, height: -175, unit_system: "metric").call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
    assert_includes result[:errors], "Height must be positive"
  end

  # --- Validation: invalid unit system ---

  test "invalid unit system returns error" do
    result = Health::BmiCalculator.new(weight: 70, height: 175, unit_system: "stones").call
    refute result[:valid]
    assert_includes result[:errors], "Invalid unit system"
  end

  # --- Upper-bound validation: metric ---

  test "metric: weight over 700 kg returns error" do
    result = Health::BmiCalculator.new(weight: 701, height: 175, unit_system: "metric").call
    refute result[:valid]
    assert_includes result[:errors], "Weight cannot exceed 700 kg"
  end

  test "metric: weight at 700 kg is accepted" do
    result = Health::BmiCalculator.new(weight: 700, height: 175, unit_system: "metric").call
    assert result[:valid]
  end

  test "metric: height over 300 cm returns error" do
    result = Health::BmiCalculator.new(weight: 70, height: 301, unit_system: "metric").call
    refute result[:valid]
    assert_includes result[:errors], "Height cannot exceed 300 cm"
  end

  test "metric: height at 300 cm is accepted" do
    result = Health::BmiCalculator.new(weight: 70, height: 300, unit_system: "metric").call
    assert result[:valid]
  end

  # --- Upper-bound validation: imperial ---

  test "imperial: weight over 1500 lbs returns error" do
    result = Health::BmiCalculator.new(weight: 1501, height: 69, unit_system: "imperial").call
    refute result[:valid]
    assert_includes result[:errors], "Weight cannot exceed 1500 lbs"
  end

  test "imperial: weight at 1500 lbs is accepted" do
    result = Health::BmiCalculator.new(weight: 1500, height: 69, unit_system: "imperial").call
    assert result[:valid]
  end

  test "imperial: height over 120 inches returns error" do
    result = Health::BmiCalculator.new(weight: 154, height: 121, unit_system: "imperial").call
    refute result[:valid]
    assert_includes result[:errors], "Height cannot exceed 120 inches"
  end

  test "imperial: height at 120 inches is accepted" do
    result = Health::BmiCalculator.new(weight: 154, height: 120, unit_system: "imperial").call
    assert result[:valid]
  end

  # --- Very large values ---

  test "very large weight within bounds" do
    result = Health::BmiCalculator.new(weight: 500, height: 175, unit_system: "metric").call
    assert result[:valid]
    assert result[:bmi] > 100
    assert_equal "Obese", result[:category]
  end

  test "errors accessor returns empty array before call" do
    calc = Health::BmiCalculator.new(weight: 70, height: 175)
    assert_equal [], calc.errors
  end
end
