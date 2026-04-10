require "test_helper"

class Construction::CabinetDoorCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "standard 12x24 shaker door with defaults" do
    result = Construction::CabinetDoorCalculator.new(door_width: 12, door_height: 24).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]

    # Stiles
    assert_equal 24.0, result[:stile_length]
    assert_equal 2.5,  result[:stile_width]
    assert_equal 2,    result[:stile_count]

    # Rails: 12 - (2 * 2.5) + (2 * 0.375) = 12 - 5 + 0.75 = 7.75
    assert_equal 7.75, result[:rail_length]
    assert_equal 2.5,  result[:rail_width]
    assert_equal 2,    result[:rail_count]

    # Panel width: 12 - 5 + 0.75 - (2 * 0.0625) = 7.625
    assert_equal 7.625, result[:panel_width]
    # Panel height: 24 - 5 + 0.75 - 0.125 = 19.625
    assert_equal 19.625, result[:panel_height]

    assert result[:total_bf].positive?
  end

  test "larger 18x36 door calculates rails and panel correctly" do
    result = Construction::CabinetDoorCalculator.new(door_width: 18, door_height: 36).call
    assert_equal true, result[:valid]
    assert_equal 36.0, result[:stile_length]
    # rail_length = 18 - 5 + 0.75 = 13.75
    assert_equal 13.75, result[:rail_length]
    # panel_width = 13.75 - 0.125 = 13.625
    assert_equal 13.625, result[:panel_width]
    # panel_height = 36 - 5 + 0.75 - 0.125 = 31.625
    assert_equal 31.625, result[:panel_height]
  end

  test "custom stile and rail widths" do
    result = Construction::CabinetDoorCalculator.new(
      door_width: 16, door_height: 30, stile_width: 2.25, rail_width: 3.0
    ).call
    assert_equal true, result[:valid]
    assert_equal 2.25, result[:stile_width]
    assert_equal 3.0,  result[:rail_width]
    # rail_length = 16 - 4.5 + 0.75 = 12.25
    assert_equal 12.25, result[:rail_length]
    # panel_height = 30 - 6 + 0.75 - 0.125 = 24.625
    assert_equal 24.625, result[:panel_height]
  end

  test "zero tongue depth and zero clearance" do
    result = Construction::CabinetDoorCalculator.new(
      door_width: 12, door_height: 24, tongue_depth: 0, panel_clearance: 0
    ).call
    assert_equal true, result[:valid]
    # rail_length = 12 - 5 + 0 = 7
    assert_equal 7.0, result[:rail_length]
    # panel_width = 7 - 0 = 7
    assert_equal 7.0, result[:panel_width]
    # panel_height = 24 - 5 + 0 - 0 = 19
    assert_equal 19.0, result[:panel_height]
  end

  test "string inputs are coerced" do
    result = Construction::CabinetDoorCalculator.new(
      door_width: "12", door_height: "24", stile_width: "2.5", rail_width: "2.5",
      tongue_depth: "0.375", panel_clearance: "0.0625"
    ).call
    assert_equal true, result[:valid]
    assert_equal 7.75, result[:rail_length]
  end

  test "large pantry-style door computes reasonable board feet" do
    result = Construction::CabinetDoorCalculator.new(door_width: 24, door_height: 60).call
    assert_equal true, result[:valid]
    assert result[:total_bf] > 1.0
  end

  # --- Validation errors ---

  test "error when door width is zero" do
    result = Construction::CabinetDoorCalculator.new(door_width: 0, door_height: 24).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Door width must be greater than zero"
  end

  test "error when door height is zero" do
    result = Construction::CabinetDoorCalculator.new(door_width: 12, door_height: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Door height must be greater than zero"
  end

  test "error when stile width is zero" do
    result = Construction::CabinetDoorCalculator.new(door_width: 12, door_height: 24, stile_width: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Stile width must be greater than zero"
  end

  test "error when rail width is zero" do
    result = Construction::CabinetDoorCalculator.new(door_width: 12, door_height: 24, rail_width: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Rail width must be greater than zero"
  end

  test "error when tongue depth is negative" do
    result = Construction::CabinetDoorCalculator.new(door_width: 12, door_height: 24, tongue_depth: -0.1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Tongue depth cannot be negative"
  end

  test "error when panel clearance is negative" do
    result = Construction::CabinetDoorCalculator.new(door_width: 12, door_height: 24, panel_clearance: -0.05).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Panel clearance cannot be negative"
  end

  test "error when stiles are wider than door" do
    result = Construction::CabinetDoorCalculator.new(door_width: 4, door_height: 24, stile_width: 2.5).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Stiles are wider than the door — increase door width or reduce stile width"
  end

  test "error when rails are taller than door" do
    result = Construction::CabinetDoorCalculator.new(door_width: 12, door_height: 4, rail_width: 2.5).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Rails are taller than the door — increase door height or reduce rail width"
  end

  test "edge case: exactly stile_width * 2 equals door width is invalid" do
    result = Construction::CabinetDoorCalculator.new(door_width: 5, door_height: 24, stile_width: 2.5).call
    assert_equal false, result[:valid]
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::CabinetDoorCalculator.new(door_width: 12, door_height: 24)
    assert_equal [], calc.errors
  end
end
