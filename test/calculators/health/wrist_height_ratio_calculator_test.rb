require "test_helper"

class Health::WristHeightRatioCalculatorTest < ActiveSupport::TestCase
  # --- Male frame sizes ---

  test "male small frame wrist under 16.5 cm" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 15.5, height: 175, gender: "male"
    ).call
    assert result[:valid]
    assert_equal :small, result[:frame_size]
    assert_equal "Small Frame", result[:frame_size_label]
  end

  test "male medium frame wrist 16.5-19 cm" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 17.5, height: 175, gender: "male"
    ).call
    assert result[:valid]
    assert_equal :medium, result[:frame_size]
  end

  test "male large frame wrist over 19 cm" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 20, height: 175, gender: "male"
    ).call
    assert result[:valid]
    assert_equal :large, result[:frame_size]
  end

  # --- Female frame sizes ---

  test "female small frame wrist under 14 cm" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 13, height: 165, gender: "female"
    ).call
    assert result[:valid]
    assert_equal :small, result[:frame_size]
  end

  test "female medium frame wrist 14-16.5 cm" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 15, height: 165, gender: "female"
    ).call
    assert result[:valid]
    assert_equal :medium, result[:frame_size]
  end

  test "female large frame wrist over 16.5 cm" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 17, height: 165, gender: "female"
    ).call
    assert result[:valid]
    assert_equal :large, result[:frame_size]
  end

  # --- Ratio calculation ---

  test "ratio is wrist divided by height" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 17, height: 175, gender: "male"
    ).call
    assert result[:valid]
    assert_in_delta 0.0971, result[:wrist_to_height_ratio], 0.001
    assert_in_delta 9.71, result[:ratio_percentage], 0.1
  end

  # --- Ideal weight calculation ---

  test "ideal weight range for medium frame male 175cm" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 17.5, height: 175, gender: "male"
    ).call
    assert result[:valid]
    # Height = 175 cm = ~68.9 inches
    # Base = 48 + (68.9 - 60) * 2.7 = 48 + 24.03 = 72.03 kg
    # Medium frame adj = 0%
    # Range: 72.03 * 0.9 to 72.03 * 1.1 = 64.8 to 79.2
    assert result[:ideal_weight_kg][:min] > 0
    assert result[:ideal_weight_kg][:max] > result[:ideal_weight_kg][:min]
  end

  test "small frame has lower ideal weight than large frame" do
    small = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 15, height: 175, gender: "male"
    ).call
    large = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 20, height: 175, gender: "male"
    ).call
    assert small[:ideal_weight_kg][:max] < large[:ideal_weight_kg][:max]
  end

  # --- Imperial units ---

  test "inches unit converts correctly" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 7, height: 69, gender: "male", unit: "inches"
    ).call
    assert result[:valid]
    assert_in_delta 17.78, result[:wrist_cm], 0.5
    assert_in_delta 175.26, result[:height_cm], 0.5
  end

  # --- LBS output ---

  test "ideal weight in lbs is provided" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 17, height: 175, gender: "male"
    ).call
    assert result[:valid]
    assert result[:ideal_weight_lbs][:min] > 0
    assert result[:ideal_weight_lbs][:max] > result[:ideal_weight_lbs][:min]
  end

  # --- Frame size ranges ---

  test "frame size ranges provided for gender" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 17, height: 175, gender: "male"
    ).call
    assert_equal 3, result[:frame_size_ranges].length
  end

  # --- Validation ---

  test "zero wrist returns error" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 0, height: 175, gender: "male"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Wrist circumference must be positive"
  end

  test "zero height returns error" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 17, height: 0, gender: "male"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  test "invalid gender returns error" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 17, height: 175, gender: "other"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Gender must be male or female"
  end

  test "invalid unit returns error" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 17, height: 175, gender: "male", unit: "meters"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Unit must be cm or inches"
  end

  test "wrist over 30 cm returns error" do
    result = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 35, height: 175, gender: "male"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Wrist circumference seems unrealistic (max 30 cm)"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::WristHeightRatioCalculator.new(
      wrist_circumference: 17, height: 175, gender: "male"
    )
    assert_equal [], calc.errors
  end
end
