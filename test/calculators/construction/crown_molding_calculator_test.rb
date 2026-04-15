require "test_helper"

class Construction::CrownMoldingCalculatorTest < ActiveSupport::TestCase
  test "12x14 room with one 3 ft door" do
    result = Construction::CrownMoldingCalculator.new(
      length_ft: 14, width_ft: 12, door_openings_ft: 3, stick_length_ft: 12, waste_pct: 0
    ).call
    assert_equal true, result[:valid]
    # Perimeter = 2×(14+12) = 52 ft; net = 49 ft; sticks = ceil(49/12) = 5
    assert_in_delta 52.0, result[:perimeter_ft], 0.01
    assert_in_delta 49.0, result[:net_linear_ft], 0.01
    assert_equal 5, result[:sticks_needed]
  end

  test "waste rounds up sticks" do
    no_waste = Construction::CrownMoldingCalculator.new(length_ft: 14, width_ft: 12, stick_length_ft: 12, waste_pct: 0).call
    with_waste = Construction::CrownMoldingCalculator.new(length_ft: 14, width_ft: 12, stick_length_ft: 12, waste_pct: 20).call
    assert with_waste[:sticks_needed] >= no_waste[:sticks_needed]
  end

  test "longer sticks mean fewer total sticks" do
    r8 = Construction::CrownMoldingCalculator.new(length_ft: 20, width_ft: 20, stick_length_ft: 8).call
    r16 = Construction::CrownMoldingCalculator.new(length_ft: 20, width_ft: 20, stick_length_ft: 16).call
    assert r16[:sticks_needed] < r8[:sticks_needed]
  end

  test "door openings reduce net linear feet" do
    no_door = Construction::CrownMoldingCalculator.new(length_ft: 14, width_ft: 12, door_openings_ft: 0).call
    with_door = Construction::CrownMoldingCalculator.new(length_ft: 14, width_ft: 12, door_openings_ft: 6).call
    assert with_door[:net_linear_ft] < no_door[:net_linear_ft]
  end

  test "error when length is zero" do
    result = Construction::CrownMoldingCalculator.new(length_ft: 0, width_ft: 12).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "error for invalid stick length" do
    result = Construction::CrownMoldingCalculator.new(length_ft: 14, width_ft: 12, stick_length_ft: 11).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Stick length") }
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::CrownMoldingCalculator.new(length_ft: 14, width_ft: 12)
    assert_equal [], calc.errors
  end
end
