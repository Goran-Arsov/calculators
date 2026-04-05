require "test_helper"

class Health::IdealWeightCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: metric male, medium frame ---

  test "metric male medium frame at 175cm" do
    result = Health::IdealWeightCalculator.new(height: 175, gender: "male", frame_size: "medium").call
    assert result[:valid]
    assert_equal "kg", result[:unit]
    # 175cm = ~68.9 inches, ~8.9 inches over 5ft
    # Devine: (50 + 2.3*8.9) * 2.20462 = ~155.4 lbs => ~70.5 kg
    assert_in_delta 70.5, result[:devine], 1.0
    assert result[:robinson] > 0
    assert result[:miller] > 0
    assert result[:hamwi] > 0
    assert result[:average] > 0
    assert_equal result[:average], result[:frame_adjusted] # medium = no adjustment
  end

  test "metric female medium frame at 165cm" do
    result = Health::IdealWeightCalculator.new(height: 165, gender: "female", frame_size: "medium").call
    assert result[:valid]
    assert_equal "kg", result[:unit]
    # 165cm = ~65 inches, 5 inches over 5ft
    # Devine: (45.5 + 2.3*5) * 2.20462 = ~124.7 lbs => ~56.6 kg
    assert_in_delta 56.6, result[:devine], 1.0
  end

  # --- Frame size adjustments ---

  test "small frame reduces ideal weight by 10%" do
    medium = Health::IdealWeightCalculator.new(height: 175, gender: "male", frame_size: "medium").call
    small = Health::IdealWeightCalculator.new(height: 175, gender: "male", frame_size: "small").call
    assert_in_delta medium[:frame_adjusted] * 0.9, small[:frame_adjusted], 0.5
  end

  test "large frame increases ideal weight by 10%" do
    medium = Health::IdealWeightCalculator.new(height: 175, gender: "male", frame_size: "medium").call
    large = Health::IdealWeightCalculator.new(height: 175, gender: "male", frame_size: "large").call
    assert_in_delta medium[:frame_adjusted] * 1.1, large[:frame_adjusted], 0.5
  end

  # --- Imperial unit system ---

  test "imperial male returns weight in lbs" do
    result = Health::IdealWeightCalculator.new(height: 70, gender: "male", frame_size: "medium", unit_system: "imperial").call
    assert result[:valid]
    assert_equal "lbs", result[:unit]
    # 70 inches = 10 inches over 5ft
    # Devine: (50 + 2.3*10) * 2.20462 = ~160.9 lbs
    assert_in_delta 160.9, result[:devine], 1.0
  end

  # --- Ideal range ---

  test "ideal range is +/-10% of frame adjusted" do
    result = Health::IdealWeightCalculator.new(height: 175, gender: "male", frame_size: "medium").call
    assert_in_delta result[:frame_adjusted] * 0.90, result[:ideal_range_min], 0.5
    assert_in_delta result[:frame_adjusted] * 1.10, result[:ideal_range_max], 0.5
  end

  # --- Validation: zero/negative height ---

  test "zero height returns error" do
    result = Health::IdealWeightCalculator.new(height: 0, gender: "male").call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  test "negative height returns error" do
    result = Health::IdealWeightCalculator.new(height: -170, gender: "male").call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  # --- Validation: invalid gender ---

  test "invalid gender returns error" do
    result = Health::IdealWeightCalculator.new(height: 175, gender: "other").call
    refute result[:valid]
    assert_includes result[:errors], "Gender must be male or female"
  end

  # --- Validation: invalid frame size ---

  test "invalid frame size returns error" do
    result = Health::IdealWeightCalculator.new(height: 175, gender: "male", frame_size: "huge").call
    refute result[:valid]
    assert_includes result[:errors], "Frame size must be small, medium, or large"
  end

  # --- Validation: invalid unit system ---

  test "invalid unit system returns error" do
    result = Health::IdealWeightCalculator.new(height: 175, gender: "male", unit_system: "stones").call
    refute result[:valid]
    assert_includes result[:errors], "Invalid unit system"
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    result = Health::IdealWeightCalculator.new(height: 0, gender: "invalid", frame_size: "huge", unit_system: "stones").call
    refute result[:valid]
    assert result[:errors].length >= 4
  end

  # --- String coercion ---

  test "string height is coerced to float" do
    result = Health::IdealWeightCalculator.new(height: "175", gender: "male").call
    assert result[:valid]
    assert result[:devine] > 0
  end

  # --- Edge case: very short person (exactly 5ft) ---

  test "exactly 60 inches uses base weight only" do
    result = Health::IdealWeightCalculator.new(height: 60, gender: "male", unit_system: "imperial").call
    assert result[:valid]
    # Devine: (50 + 2.3*0) * 2.20462 = 110.2 lbs
    assert_in_delta 110.2, result[:devine], 0.5
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::IdealWeightCalculator.new(height: 175, gender: "male")
    assert_equal [], calc.errors
  end
end
