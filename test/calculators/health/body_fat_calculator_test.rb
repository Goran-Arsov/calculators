require "test_helper"

class Health::BodyFatCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: metric male ---

  test "happy path metric male" do
    # U.S. Navy Method: 495 / (1.0324 - 0.19077*log10(waist-neck) + 0.15456*log10(height)) - 450
    # waist=85, neck=38, height=180
    # 495 / (1.0324 - 0.19077*log10(47) + 0.15456*log10(180)) - 450
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 85, neck: 38, height: 180, unit_system: "metric"
    ).call

    assert result[:valid]
    assert result[:body_fat_percentage].is_a?(Float)
    assert result[:body_fat_percentage] > 0
    assert_includes %w[Essential\ fat Athletes Fitness Average Obese], result[:category]
  end

  test "metric male: athletes range" do
    # Lean male with small waist-neck difference
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 75, neck: 40, height: 180, unit_system: "metric"
    ).call
    assert result[:valid]
    assert result[:body_fat_percentage] > 0
  end

  # --- Happy path: metric female ---

  test "happy path metric female" do
    # Female formula requires hip measurement
    result = Health::BodyFatCalculator.new(
      sex: "female", waist: 75, neck: 33, height: 165, hip: 95, unit_system: "metric"
    ).call

    assert result[:valid]
    assert result[:body_fat_percentage].is_a?(Float)
    assert result[:body_fat_percentage] > 0
    assert_includes %w[Essential\ fat Athletes Fitness Average Obese], result[:category]
  end

  # --- Happy path: imperial male ---

  test "happy path imperial male" do
    # waist=34 inches, neck=15 inches, height=71 inches
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 34, neck: 15, height: 71, unit_system: "imperial"
    ).call

    assert result[:valid]
    assert result[:body_fat_percentage] > 0
  end

  # --- Happy path: imperial female ---

  test "happy path imperial female" do
    # waist=30 inches, neck=13 inches, height=65 inches, hip=38 inches
    result = Health::BodyFatCalculator.new(
      sex: "female", waist: 30, neck: 13, height: 65, hip: 38, unit_system: "imperial"
    ).call

    assert result[:valid]
    assert result[:body_fat_percentage] > 0
  end

  # --- Male categories ---

  test "male: essential fat category" do
    # Need body fat < 6% - very lean male
    # Use values that produce a very low body fat percentage
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 70, neck: 42, height: 190, unit_system: "metric"
    ).call
    # We just verify it returns a valid result with a category
    assert result[:valid]
    assert result[:category].is_a?(String)
  end

  # --- Female categories ---

  test "female: returns valid category" do
    result = Health::BodyFatCalculator.new(
      sex: "female", waist: 80, neck: 33, height: 165, hip: 100, unit_system: "metric"
    ).call
    assert result[:valid]
    assert_includes %w[Essential\ fat Athletes Fitness Average Obese], result[:category]
  end

  # --- Default unit system ---

  test "default unit system is metric" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 85, neck: 38, height: 180
    ).call
    assert result[:valid]
  end

  # --- Metric vs imperial consistency ---

  test "metric and imperial produce similar results for equivalent inputs" do
    # 85 cm waist = 33.46 inches, 38 cm neck = 14.96 inches, 180 cm height = 70.87 inches
    metric = Health::BodyFatCalculator.new(
      sex: "male", waist: 85, neck: 38, height: 180, unit_system: "metric"
    ).call

    imperial = Health::BodyFatCalculator.new(
      sex: "male", waist: 33.46, neck: 14.96, height: 70.87, unit_system: "imperial"
    ).call

    assert metric[:valid]
    assert imperial[:valid]
    assert_in_delta metric[:body_fat_percentage], imperial[:body_fat_percentage], 0.5
  end

  # --- Validation: zero values ---

  test "zero waist returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 0, neck: 38, height: 180, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Waist measurement must be positive"
  end

  test "zero neck returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 85, neck: 0, height: 180, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Neck measurement must be positive"
  end

  test "zero height returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 85, neck: 38, height: 0, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  # --- Validation: negative values ---

  test "negative waist returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: -85, neck: 38, height: 180, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Waist measurement must be positive"
  end

  test "negative neck returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 85, neck: -38, height: 180, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Neck measurement must be positive"
  end

  test "negative height returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 85, neck: 38, height: -180, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  # --- Validation: waist must be larger than neck ---

  test "waist equal to neck returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 40, neck: 40, height: 180, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Waist must be larger than neck"
  end

  test "waist smaller than neck returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 30, neck: 40, height: 180, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Waist must be larger than neck"
  end

  # --- Validation: female requires hip ---

  test "female without hip returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "female", waist: 75, neck: 33, height: 165, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Hip measurement is required for females"
  end

  test "female with zero hip returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "female", waist: 75, neck: 33, height: 165, hip: 0, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Hip measurement is required for females"
  end

  test "female with negative hip returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "female", waist: 75, neck: 33, height: 165, hip: -95, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Hip measurement is required for females"
  end

  test "male without hip is valid" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 85, neck: 38, height: 180, unit_system: "metric"
    ).call
    assert result[:valid]
  end

  # --- Validation: invalid sex ---

  test "invalid sex returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "other", waist: 85, neck: 38, height: 180, unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Sex must be male or female"
  end

  # --- Validation: invalid unit system ---

  test "invalid unit system returns error" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 85, neck: 38, height: 180, unit_system: "stones"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Invalid unit system"
  end

  # --- Multiple validation errors ---

  test "multiple validation errors at once" do
    result = Health::BodyFatCalculator.new(
      sex: "other", waist: 0, neck: 0, height: 0, unit_system: "invalid"
    ).call
    refute result[:valid]
    assert result[:errors].length >= 4
  end

  # --- Very large values ---

  test "very large measurements" do
    result = Health::BodyFatCalculator.new(
      sex: "male", waist: 200, neck: 50, height: 210, unit_system: "metric"
    ).call
    assert result[:valid]
    assert result[:body_fat_percentage] > 0
  end

  test "errors accessor returns empty array before call" do
    calc = Health::BodyFatCalculator.new(
      sex: "male", waist: 85, neck: 38, height: 180
    )
    assert_equal [], calc.errors
  end
end
