require "test_helper"

class Health::LeanBodyMassCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: body fat percentage method ---

  test "from body fat percentage 80kg 20 percent" do
    result = Health::LeanBodyMassCalculator.new(weight: 80, body_fat_percentage: 20).call
    assert result[:valid]
    assert_equal "body_fat_percentage", result[:method]
    # Fat mass: 80 * 0.20 = 16.0
    assert_in_delta 16.0, result[:fat_mass], 0.1
    # Lean mass: 80 - 16 = 64.0
    assert_in_delta 64.0, result[:lean_body_mass], 0.1
    assert_in_delta 20.0, result[:body_fat_percentage], 0.1
    assert_in_delta 80.0, result[:lean_percentage], 0.1
    assert_equal "kg", result[:unit]
  end

  test "from body fat percentage imperial" do
    result = Health::LeanBodyMassCalculator.new(weight: 200, body_fat_percentage: 25, unit_system: "imperial").call
    assert result[:valid]
    assert_in_delta 50.0, result[:fat_mass], 0.1  # 200 * 0.25
    assert_in_delta 150.0, result[:lean_body_mass], 0.1
    assert_equal "lbs", result[:unit]
  end

  # --- Happy path: formula method, male ---

  test "formula method male 80kg 175cm" do
    result = Health::LeanBodyMassCalculator.new(weight: 80, gender: "male", height: 175).call
    assert result[:valid]
    assert_equal "formula", result[:method]
    # Boer: 0.407 * 80 + 0.267 * 175 - 19.2 = 32.56 + 46.725 - 19.2 = 60.085
    assert_in_delta 60.1, result[:boer_lbm], 0.5
    # James: 1.1 * 80 - 128 * (80/175)^2 = 88 - 128 * 0.2089 = 88 - 26.74 = 61.26
    assert_in_delta 61.3, result[:james_lbm], 0.5
    # Hume: 0.32810 * 80 + 0.33929 * 175 - 29.5336 = 26.248 + 59.376 - 29.5336 = 56.09
    assert_in_delta 56.1, result[:hume_lbm], 0.5
    assert result[:lean_body_mass] > 0
    assert result[:fat_mass] > 0
  end

  # --- Formula method, female ---

  test "formula method female 65kg 165cm" do
    result = Health::LeanBodyMassCalculator.new(weight: 65, gender: "female", height: 165).call
    assert result[:valid]
    # Boer: 0.252 * 65 + 0.473 * 165 - 48.3 = 16.38 + 78.045 - 48.3 = 46.125
    assert_in_delta 46.1, result[:boer_lbm], 0.5
  end

  # --- Formula method, imperial ---

  test "formula method imperial male" do
    result = Health::LeanBodyMassCalculator.new(weight: 176, gender: "male", height: 69, unit_system: "imperial").call
    assert result[:valid]
    assert_equal "lbs", result[:unit]
    # Converts to kg/cm internally: 176 * 0.453592 = 79.83, 69 * 2.54 = 175.26
    # Then converts back to lbs for output
    assert result[:lean_body_mass] > 100 # should be in lbs
    assert result[:boer_lbm] > 100
  end

  # --- Body fat percentage is calculated from formula ---

  test "formula method calculates body fat percentage" do
    result = Health::LeanBodyMassCalculator.new(weight: 80, gender: "male", height: 175).call
    assert result[:valid]
    # BF% should be (fat_mass_kg / weight_kg * 100)
    expected_bf = ((80.0 - result[:lean_body_mass]) / 80.0 * 100)
    assert_in_delta expected_bf, result[:body_fat_percentage], 0.5
  end

  # --- Lean percentage complements body fat ---

  test "lean percentage plus body fat equals 100" do
    result = Health::LeanBodyMassCalculator.new(weight: 80, body_fat_percentage: 20).call
    assert_in_delta 100.0, result[:lean_percentage] + result[:body_fat_percentage], 0.1
  end

  # --- Validation: zero weight ---

  test "zero weight returns error" do
    result = Health::LeanBodyMassCalculator.new(weight: 0, body_fat_percentage: 20).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "negative weight returns error" do
    result = Health::LeanBodyMassCalculator.new(weight: -80, body_fat_percentage: 20).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  # --- Validation: body fat percentage ---

  test "body fat percentage below 1 returns error" do
    result = Health::LeanBodyMassCalculator.new(weight: 80, body_fat_percentage: 0.5).call
    refute result[:valid]
    assert_includes result[:errors], "Body fat percentage must be between 1 and 70"
  end

  test "body fat percentage above 70 returns error" do
    result = Health::LeanBodyMassCalculator.new(weight: 80, body_fat_percentage: 75).call
    refute result[:valid]
    assert_includes result[:errors], "Body fat percentage must be between 1 and 70"
  end

  # --- Validation: formula method without gender/height ---

  test "formula method without gender returns error" do
    result = Health::LeanBodyMassCalculator.new(weight: 80, height: 175).call
    refute result[:valid]
    assert_includes result[:errors], "Gender is required when using formula method"
  end

  test "formula method without height returns error" do
    result = Health::LeanBodyMassCalculator.new(weight: 80, gender: "male").call
    refute result[:valid]
    assert_includes result[:errors], "Height is required when using formula method"
  end

  # --- Validation: invalid unit system ---

  test "invalid unit system returns error" do
    result = Health::LeanBodyMassCalculator.new(weight: 80, body_fat_percentage: 20, unit_system: "stones").call
    refute result[:valid]
    assert_includes result[:errors], "Invalid unit system"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Health::LeanBodyMassCalculator.new(weight: "80", body_fat_percentage: "20").call
    assert result[:valid]
    assert_in_delta 64.0, result[:lean_body_mass], 0.1
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::LeanBodyMassCalculator.new(weight: 80, body_fat_percentage: 20)
    assert_equal [], calc.errors
  end

  # --- Edge case: very low body fat ---

  test "very low body fat percentage athlete" do
    result = Health::LeanBodyMassCalculator.new(weight: 80, body_fat_percentage: 5).call
    assert result[:valid]
    assert_in_delta 76.0, result[:lean_body_mass], 0.1
    assert_in_delta 4.0, result[:fat_mass], 0.1
  end
end
