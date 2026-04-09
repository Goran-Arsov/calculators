require "test_helper"

class Health::FfmiCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: average male" do
    # 80 kg, 180 cm, 15% bf
    # lean = 80 * (1 - 0.15) = 68, fat = 12
    # ffmi = 68 / 1.8^2 = 68 / 3.24 = 20.99
    # adj = 20.99 + 6.1 * (1.8 - 1.8) = 20.99
    result = Health::FfmiCalculator.new(weight_kg: 80, height_cm: 180, body_fat_percent: 15).call
    assert result[:valid]
    assert_in_delta 68.0, result[:lean_mass_kg], 0.1
    assert_in_delta 12.0, result[:fat_mass_kg], 0.1
    assert_in_delta 20.99, result[:ffmi], 0.1
    assert_in_delta 20.99, result[:adjusted_ffmi], 0.1
    assert_equal "Above Average", result[:category]
  end

  test "below average ffmi" do
    # 60 kg, 180 cm, 20% bf
    # lean = 60 * 0.8 = 48, ffmi = 48 / 3.24 = 14.81
    # adj = 14.81 + 6.1 * (1.8 - 1.8) = 14.81
    result = Health::FfmiCalculator.new(weight_kg: 60, height_cm: 180, body_fat_percent: 20).call
    assert result[:valid]
    assert result[:adjusted_ffmi] < 18
    assert_equal "Below Average", result[:category]
  end

  test "average ffmi" do
    # Need adjusted ~19
    # 70 kg, 175 cm, 12% bf
    # lean = 70 * 0.88 = 61.6, ffmi = 61.6 / 1.75^2 = 61.6 / 3.0625 = 20.11
    # adj = 20.11 + 6.1 * (1.8 - 1.75) = 20.11 + 0.305 = 20.42
    # Actually above average, let me adjust
    # 65 kg, 180 cm, 15% bf
    # lean = 65 * 0.85 = 55.25, ffmi = 55.25 / 3.24 = 17.05
    # adj = 17.05 + 0 = 17.05 (below average still)
    # 70 kg, 180 cm, 12% bf
    # lean = 70 * 0.88 = 61.6, ffmi = 61.6 / 3.24 = 19.01
    # adj = 19.01 + 0 = 19.01
    result = Health::FfmiCalculator.new(weight_kg: 70, height_cm: 180, body_fat_percent: 12).call
    assert result[:valid]
    assert result[:adjusted_ffmi] >= 18
    assert result[:adjusted_ffmi] < 20
    assert_equal "Average", result[:category]
  end

  test "excellent ffmi" do
    # 90 kg, 175 cm, 10% bf
    # lean = 90 * 0.9 = 81, ffmi = 81 / 3.0625 = 26.45
    # adj = 26.45 + 6.1 * (1.8 - 1.75) = 26.45 + 0.305 = 26.755
    # That's superior. Try 85 kg, 180 cm, 12% bf
    # lean = 85 * 0.88 = 74.8, ffmi = 74.8 / 3.24 = 23.09
    # adj = 23.09 + 0 = 23.09
    result = Health::FfmiCalculator.new(weight_kg: 85, height_cm: 180, body_fat_percent: 12).call
    assert result[:valid]
    assert result[:adjusted_ffmi] >= 22
    assert result[:adjusted_ffmi] < 25
    assert_equal "Excellent", result[:category]
  end

  test "superior ffmi" do
    # 100 kg, 175 cm, 8% bf
    # lean = 100 * 0.92 = 92, ffmi = 92 / 3.0625 = 30.04
    # adj = 30.04 + 6.1 * 0.05 = 30.04 + 0.305 = 30.35
    result = Health::FfmiCalculator.new(weight_kg: 100, height_cm: 175, body_fat_percent: 8).call
    assert result[:valid]
    assert result[:adjusted_ffmi] >= 25
    assert_equal "Superior / Elite", result[:category]
  end

  # --- Height adjustment ---

  test "adjusted ffmi differs for shorter individuals" do
    # 80 kg, 170 cm, 15% bf
    # lean = 68, ffmi = 68 / 1.7^2 = 68 / 2.89 = 23.53
    # adj = 23.53 + 6.1 * (1.8 - 1.7) = 23.53 + 0.61 = 24.14
    result = Health::FfmiCalculator.new(weight_kg: 80, height_cm: 170, body_fat_percent: 15).call
    assert result[:valid]
    assert result[:adjusted_ffmi] > result[:ffmi], "Adjusted FFMI should be higher for shorter people"
  end

  test "adjusted ffmi differs for taller individuals" do
    # 80 kg, 190 cm, 15% bf
    # lean = 68, ffmi = 68 / 1.9^2 = 68 / 3.61 = 18.84
    # adj = 18.84 + 6.1 * (1.8 - 1.9) = 18.84 - 0.61 = 18.23
    result = Health::FfmiCalculator.new(weight_kg: 80, height_cm: 190, body_fat_percent: 15).call
    assert result[:valid]
    assert result[:adjusted_ffmi] < result[:ffmi], "Adjusted FFMI should be lower for taller people"
  end

  # --- Fat and lean mass ---

  test "lean mass and fat mass sum to total weight" do
    result = Health::FfmiCalculator.new(weight_kg: 80, height_cm: 180, body_fat_percent: 15).call
    assert result[:valid]
    assert_in_delta 80.0, result[:lean_mass_kg] + result[:fat_mass_kg], 0.01
  end

  # --- Edge: zero body fat ---

  test "zero body fat percent" do
    result = Health::FfmiCalculator.new(weight_kg: 80, height_cm: 180, body_fat_percent: 0).call
    assert result[:valid]
    assert_in_delta 80.0, result[:lean_mass_kg], 0.01
    assert_in_delta 0.0, result[:fat_mass_kg], 0.01
  end

  # --- Validation: zero/negative values ---

  test "zero weight returns error" do
    result = Health::FfmiCalculator.new(weight_kg: 0, height_cm: 180, body_fat_percent: 15).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "zero height returns error" do
    result = Health::FfmiCalculator.new(weight_kg: 80, height_cm: 0, body_fat_percent: 15).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  test "negative weight returns error" do
    result = Health::FfmiCalculator.new(weight_kg: -80, height_cm: 180, body_fat_percent: 15).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "negative height returns error" do
    result = Health::FfmiCalculator.new(weight_kg: 80, height_cm: -180, body_fat_percent: 15).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  # --- Validation: body fat percent ---

  test "body fat percent over 70 returns error" do
    result = Health::FfmiCalculator.new(weight_kg: 80, height_cm: 180, body_fat_percent: 71).call
    refute result[:valid]
    assert_includes result[:errors], "Body fat percent must be between 0 and 70"
  end

  test "negative body fat percent returns error" do
    result = Health::FfmiCalculator.new(weight_kg: 80, height_cm: 180, body_fat_percent: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Body fat percent must be between 0 and 70"
  end

  test "body fat at 70 percent is accepted" do
    result = Health::FfmiCalculator.new(weight_kg: 80, height_cm: 180, body_fat_percent: 70).call
    assert result[:valid]
  end

  # --- Validation: upper bounds ---

  test "weight over 300 kg returns error" do
    result = Health::FfmiCalculator.new(weight_kg: 301, height_cm: 180, body_fat_percent: 15).call
    refute result[:valid]
    assert_includes result[:errors], "Weight cannot exceed 300 kg"
  end

  test "height over 250 cm returns error" do
    result = Health::FfmiCalculator.new(weight_kg: 80, height_cm: 251, body_fat_percent: 15).call
    refute result[:valid]
    assert_includes result[:errors], "Height cannot exceed 250 cm"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::FfmiCalculator.new(weight_kg: 80, height_cm: 180, body_fat_percent: 15)
    assert_equal [], calc.errors
  end
end
