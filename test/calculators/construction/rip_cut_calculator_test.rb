require "test_helper"

class Construction::RipCutCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "12 inch board ripped into 2.5 inch strips with 1/8 kerf" do
    result = Construction::RipCutCalculator.new(board_width: 12, rip_width: 2.5, kerf_width: 0.125).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # (12 + 0.125) / (2.5 + 0.125) = 12.125 / 2.625 = 4.619... → floor = 4
    assert_equal 4, result[:num_strips]
    # material_used = 4 * 2.5 + 3 * 0.125 = 10 + 0.375 = 10.375
    assert_equal 10.375, result[:material_used]
    assert_equal 0.375, result[:kerf_waste]
    assert_equal 1.625, result[:leftover]
    # efficiency = 10 / 12 * 100 = 83.33
    assert_equal 83.33, result[:efficiency_percent]
  end

  test "perfect fit with zero kerf" do
    result = Construction::RipCutCalculator.new(board_width: 10, rip_width: 2.5, kerf_width: 0).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 4, result[:num_strips]
    assert_equal 10.0, result[:material_used]
    assert_equal 0.0, result[:kerf_waste]
    assert_equal 0.0, result[:leftover]
    assert_equal 100.0, result[:efficiency_percent]
  end

  test "default kerf is 0.125 inches" do
    result = Construction::RipCutCalculator.new(board_width: 12, rip_width: 2.5).call
    assert_equal true, result[:valid]
    assert_equal 0.125, result[:kerf_width]
  end

  test "single strip when board equals rip width" do
    result = Construction::RipCutCalculator.new(board_width: 3, rip_width: 3, kerf_width: 0.125).call
    assert_equal true, result[:valid]
    assert_equal 1, result[:num_strips]
    # no cuts needed for a single strip
    assert_equal 0.0, result[:kerf_waste]
    assert_equal 3.0, result[:material_used]
    assert_equal 0.0, result[:leftover]
  end

  test "thin kerf blade wastes less material" do
    thin = Construction::RipCutCalculator.new(board_width: 24, rip_width: 2, kerf_width: 0.094).call
    standard = Construction::RipCutCalculator.new(board_width: 24, rip_width: 2, kerf_width: 0.125).call
    assert thin[:kerf_waste] < standard[:kerf_waste]
  end

  test "string inputs are coerced" do
    result = Construction::RipCutCalculator.new(board_width: "12", rip_width: "2.5", kerf_width: "0.125").call
    assert_equal true, result[:valid]
    assert_equal 4, result[:num_strips]
  end

  # --- Edge cases ---

  test "rip width wider than board returns zero strips without error" do
    result = Construction::RipCutCalculator.new(board_width: 4, rip_width: 6, kerf_width: 0.125).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0, result[:num_strips]
    assert_equal 0.0, result[:material_used]
    assert_equal 0.0, result[:kerf_waste]
    assert_equal 4.0, result[:leftover]
    assert_equal 0.0, result[:efficiency_percent]
  end

  test "large board with many strips" do
    result = Construction::RipCutCalculator.new(board_width: 48, rip_width: 1, kerf_width: 0.125).call
    assert_equal true, result[:valid]
    # (48 + 0.125) / (1 + 0.125) = 48.125 / 1.125 = 42.77 → floor 42
    assert_equal 42, result[:num_strips]
    # material_used = 42 * 1 + 41 * 0.125 = 42 + 5.125 = 47.125
    assert_equal 47.125, result[:material_used]
  end

  # --- Validation errors ---

  test "error when board width is zero" do
    result = Construction::RipCutCalculator.new(board_width: 0, rip_width: 2.5).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Board width must be greater than zero"
  end

  test "error when rip width is zero" do
    result = Construction::RipCutCalculator.new(board_width: 12, rip_width: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Rip width must be greater than zero"
  end

  test "error when kerf width is negative" do
    result = Construction::RipCutCalculator.new(board_width: 12, rip_width: 2.5, kerf_width: -0.1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Kerf width cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::RipCutCalculator.new(board_width: 12, rip_width: 2.5)
    assert_equal [], calc.errors
  end
end
