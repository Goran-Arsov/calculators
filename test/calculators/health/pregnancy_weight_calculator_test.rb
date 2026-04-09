require "test_helper"

class Health::PregnancyWeightCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: normal weight ---

  test "normal weight BMI returns correct category and guidelines" do
    # 65 kg, 165 cm => BMI = 65 / (1.65^2) = 23.9 => Normal weight
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 165, current_week: 20
    ).call
    assert result[:valid]
    assert_in_delta 23.9, result[:pre_pregnancy_bmi], 0.1
    assert_equal "Normal weight", result[:bmi_category]
    assert_equal 11.3, result[:recommended_total_gain_range][:min]
    assert_equal 15.9, result[:recommended_total_gain_range][:max]
    assert_equal 0.42, result[:weekly_gain_rate]
  end

  # --- BMI category tests ---

  test "underweight BMI category" do
    # 45 kg, 165 cm => BMI = 45 / (1.65^2) = 16.5
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 45, height_cm: 165, current_week: 10
    ).call
    assert result[:valid]
    assert_equal "Underweight", result[:bmi_category]
    assert_equal 12.7, result[:recommended_total_gain_range][:min]
    assert_equal 18.1, result[:recommended_total_gain_range][:max]
    assert_equal 0.51, result[:weekly_gain_rate]
  end

  test "overweight BMI category" do
    # 75 kg, 165 cm => BMI = 75 / (1.65^2) = 27.5
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 75, height_cm: 165, current_week: 20
    ).call
    assert result[:valid]
    assert_equal "Overweight", result[:bmi_category]
    assert_equal 6.8, result[:recommended_total_gain_range][:min]
    assert_equal 11.3, result[:recommended_total_gain_range][:max]
    assert_equal 0.28, result[:weekly_gain_rate]
  end

  test "obese BMI category" do
    # 95 kg, 165 cm => BMI = 95 / (1.65^2) = 34.9
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 95, height_cm: 165, current_week: 20
    ).call
    assert result[:valid]
    assert_equal "Obese", result[:bmi_category]
    assert_equal 5.0, result[:recommended_total_gain_range][:min]
    assert_equal 9.1, result[:recommended_total_gain_range][:max]
    assert_equal 0.22, result[:weekly_gain_rate]
  end

  # --- First trimester gain ---

  test "first trimester week 1 has minimal gain" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 165, current_week: 1
    ).call
    assert result[:valid]
    # Week 1 of 13: fraction = 1/13
    assert_in_delta 0.0, result[:current_expected_gain_range][:min], 0.1
    assert_in_delta 0.2, result[:current_expected_gain_range][:max], 0.1
  end

  test "first trimester week 13 has full first tri gain" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 165, current_week: 13
    ).call
    assert result[:valid]
    assert_in_delta 0.5, result[:current_expected_gain_range][:min], 0.1
    assert_in_delta 2.0, result[:current_expected_gain_range][:max], 0.1
  end

  # --- Second/third trimester gain ---

  test "week 20 includes first tri gain plus weekly rate" do
    # Normal weight: weekly_rate = 0.42, weeks past 13 = 7
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 165, current_week: 20
    ).call
    assert result[:valid]
    # min = 0.5 + 0.42 * 7 = 3.44
    # max = 2.0 + 0.42 * 7 = 4.94
    assert_in_delta 3.4, result[:current_expected_gain_range][:min], 0.1
    assert_in_delta 4.9, result[:current_expected_gain_range][:max], 0.1
  end

  test "week 40 full term gain" do
    # Normal weight: weekly_rate = 0.42, weeks past 13 = 27
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 165, current_week: 40
    ).call
    assert result[:valid]
    # min = 0.5 + 0.42 * 27 = 11.84
    # max = 2.0 + 0.42 * 27 = 13.34
    assert_in_delta 11.8, result[:current_expected_gain_range][:min], 0.1
    assert_in_delta 13.3, result[:current_expected_gain_range][:max], 0.1
  end

  # --- BMI boundary tests ---

  test "boundary at 18.5 is normal weight" do
    # BMI exactly 18.5 => Normal weight
    height_m = 1.65
    weight = 18.5 * height_m**2
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: weight, height_cm: 165, current_week: 20
    ).call
    assert result[:valid]
    assert_equal "Normal weight", result[:bmi_category]
  end

  test "boundary at 25 is overweight" do
    # Use a weight that produces a BMI clearly at 25.0+
    # 68.1 kg at 165 cm => BMI = 68.1 / 1.65^2 = 25.01
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 68.1, height_cm: 165, current_week: 20
    ).call
    assert result[:valid]
    assert_equal "Overweight", result[:bmi_category]
  end

  test "boundary at 30 is obese" do
    height_m = 1.65
    weight = 30.0 * height_m**2
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: weight, height_cm: 165, current_week: 20
    ).call
    assert result[:valid]
    assert_equal "Obese", result[:bmi_category]
  end

  # --- Validation: zero/negative values ---

  test "zero weight returns error" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 0, height_cm: 165, current_week: 20
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Pre-pregnancy weight must be positive"
  end

  test "negative weight returns error" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: -60, height_cm: 165, current_week: 20
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Pre-pregnancy weight must be positive"
  end

  test "zero height returns error" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 0, current_week: 20
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  test "negative height returns error" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: -165, current_week: 20
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  # --- Validation: week range ---

  test "week 0 returns error" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 165, current_week: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Current week must be between 1 and 42"
  end

  test "week 43 returns error" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 165, current_week: 43
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Current week must be between 1 and 42"
  end

  test "week 1 is accepted" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 165, current_week: 1
    ).call
    assert result[:valid]
  end

  test "week 42 is accepted" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 165, current_week: 42
    ).call
    assert result[:valid]
  end

  # --- Validation: upper bounds ---

  test "weight over 300 kg returns error" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 301, height_cm: 165, current_week: 20
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Weight cannot exceed 300 kg"
  end

  test "height over 300 cm returns error" do
    result = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 301, current_week: 20
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Height cannot exceed 300 cm"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::PregnancyWeightCalculator.new(
      pre_pregnancy_weight_kg: 65, height_cm: 165, current_week: 20
    )
    assert_equal [], calc.errors
  end
end
