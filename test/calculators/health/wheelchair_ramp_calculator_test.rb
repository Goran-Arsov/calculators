require "test_helper"

class Health::WheelchairRampCalculatorTest < ActiveSupport::TestCase
  # --- ADA 1:12 ratio ---

  test "24 inch rise gives 288 inch run for ADA" do
    result = Health::WheelchairRampCalculator.new(rise: 24).call
    assert result[:valid]
    assert_equal 288.0, result[:ada][:run_inches]
    assert_equal 24.0, result[:ada][:run_feet]
  end

  test "ADA angle is approximately 4.76 degrees" do
    result = Health::WheelchairRampCalculator.new(rise: 24).call
    assert result[:valid]
    assert_in_delta 4.76, result[:ada][:angle_degrees], 0.1
  end

  # --- Commercial 1:16 ratio ---

  test "24 inch rise gives 384 inch run for commercial" do
    result = Health::WheelchairRampCalculator.new(rise: 24).call
    assert result[:valid]
    assert_equal 384.0, result[:commercial][:run_inches]
    assert_equal 32.0, result[:commercial][:run_feet]
  end

  test "commercial angle is approximately 3.58 degrees" do
    result = Health::WheelchairRampCalculator.new(rise: 24).call
    assert result[:valid]
    assert_in_delta 3.58, result[:commercial][:angle_degrees], 0.1
  end

  # --- Landing requirements ---

  test "small rise needs no intermediate landings" do
    result = Health::WheelchairRampCalculator.new(rise: 12).call
    assert result[:valid]
    # 12 * 12 = 144 inches, under 360 max
    assert_equal 0, result[:ada][:landings_required]
  end

  test "large rise needs intermediate landings for ADA" do
    result = Health::WheelchairRampCalculator.new(rise: 60).call
    assert result[:valid]
    # 60 * 12 = 720 inches, 720/360 = 2 segments, 1 landing
    assert_equal 1, result[:ada][:landings_required]
  end

  # --- CM unit conversion ---

  test "cm unit converts to inches correctly" do
    result = Health::WheelchairRampCalculator.new(rise: 60.96, unit: "cm").call
    assert result[:valid]
    # 60.96 cm = 24 inches
    assert_in_delta 24.0, result[:rise_inches], 0.1
    assert_in_delta 288.0, result[:ada][:run_inches], 1.0
  end

  # --- Ramp length (hypotenuse) ---

  test "ramp length is hypotenuse of rise and run" do
    result = Health::WheelchairRampCalculator.new(rise: 24).call
    assert result[:valid]
    # sqrt(24^2 + 288^2) = sqrt(576 + 82944) = sqrt(83520) ≈ 289.0
    expected = Math.sqrt(24**2 + 288**2)
    assert_in_delta expected, result[:ada][:ramp_length_inches], 0.5
  end

  # --- Validation ---

  test "zero rise returns error" do
    result = Health::WheelchairRampCalculator.new(rise: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Rise must be positive"
  end

  test "negative rise returns error" do
    result = Health::WheelchairRampCalculator.new(rise: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Rise must be positive"
  end

  test "rise over 120 inches returns error" do
    result = Health::WheelchairRampCalculator.new(rise: 130).call
    refute result[:valid]
    assert_includes result[:errors], "Rise seems unrealistically high (max 120 inches / 300 cm)"
  end

  test "invalid unit returns error" do
    result = Health::WheelchairRampCalculator.new(rise: 24, unit: "feet").call
    refute result[:valid]
    assert_includes result[:errors], "Unit must be inches or cm"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::WheelchairRampCalculator.new(rise: 24)
    assert_equal [], calc.errors
  end
end
