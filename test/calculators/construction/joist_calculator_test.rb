require "test_helper"

class Construction::JoistCalculatorTest < ActiveSupport::TestCase
  test "12x16 room with 2x10 @ 16 OC" do
    result = Construction::JoistCalculator.new(
      room_length_ft: 16, room_width_ft: 12, joist_size: "2x10", spacing_in: 16, species: "spf_2"
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 16 ft × 12 in / 16 = 12 + 1 = 13 joists spanning the 12 ft dimension
    assert_equal 13, result[:joist_count]
    assert_equal 12.0, result[:span_ft]
    assert_equal 16.0, result[:carry_ft]
    assert_in_delta 156.0, result[:total_linear_ft], 0.01
  end

  test "span within max IRC allowed" do
    result = Construction::JoistCalculator.new(
      room_length_ft: 15, room_width_ft: 12, joist_size: "2x10", spacing_in: 16, species: "spf_2"
    ).call
    assert_equal true, result[:span_ok]
    assert result[:max_span_ft] > 12.0
  end

  test "span exceeds max IRC allowed" do
    # 2x6 @ 16 OC SPF can only span ~9.75 ft; 15 ft exceeds.
    result = Construction::JoistCalculator.new(
      room_length_ft: 15, room_width_ft: 12, joist_size: "2x6", spacing_in: 16, species: "spf_2"
    ).call
    assert_equal false, result[:span_ok]
  end

  test "board feet calculated from joist size" do
    r2x8 = Construction::JoistCalculator.new(room_length_ft: 12, room_width_ft: 10, joist_size: "2x8").call
    r2x12 = Construction::JoistCalculator.new(room_length_ft: 12, room_width_ft: 10, joist_size: "2x12").call
    # 2x12 yields roughly 1.5× the board feet of 2x8 (2.0 vs 1.333 per linear ft)
    assert r2x12[:board_feet] > r2x8[:board_feet]
  end

  test "tighter spacing produces more joists" do
    r16 = Construction::JoistCalculator.new(room_length_ft: 16, room_width_ft: 12, spacing_in: 16).call
    r12 = Construction::JoistCalculator.new(room_length_ft: 16, room_width_ft: 12, spacing_in: 12).call
    assert r12[:joist_count] > r16[:joist_count]
  end

  test "error when room length is zero" do
    result = Construction::JoistCalculator.new(room_length_ft: 0, room_width_ft: 12).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Room length must be greater than zero"
  end

  test "error for invalid joist size" do
    result = Construction::JoistCalculator.new(room_length_ft: 16, room_width_ft: 12, joist_size: "2x4").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Joist size must be 2x6, 2x8, 2x10, or 2x12"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::JoistCalculator.new(room_length_ft: 16, room_width_ft: 12)
    assert_equal [], calc.errors
  end
end
