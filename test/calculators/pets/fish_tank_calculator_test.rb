require "test_helper"

class Pets::FishTankCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates volume for rectangular tank" do
    # 24 x 12 x 16 = 4608 cubic inches * 0.9 * 0.004329 = ~17.9 gallons
    result = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16).call
    assert result[:valid]
    assert_in_delta 17.9, result[:volume_gallons], 0.5
  end

  test "calculates volume in liters" do
    result = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16).call
    assert result[:valid]
    expected_liters = result[:volume_gallons] * 3.78541
    assert_in_delta expected_liters, result[:volume_liters], 0.5
  end

  test "calculates max fish inches from volume" do
    # 24 x 12 x 16 = 4608 cubic inches * 0.9 * 0.004329 = ~17.95 gallons => floor = 17
    result = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16).call
    assert result[:valid]
    assert_equal 17, result[:max_fish_inches]
    assert result[:max_fish_inches] > 0
  end

  test "returns all expected fields" do
    result = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16).call
    assert result[:valid]
    assert result[:volume_gallons]
    assert result[:volume_liters]
    assert result[:max_fish_inches]
    assert result[:recommended_filter_gph]
    assert result[:recommended_heater_watts]
  end

  # --- Tank shapes ---

  test "bow front is larger than rectangular" do
    rect = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16, tank_shape: "rectangular").call
    bow = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16, tank_shape: "bow_front").call
    assert bow[:volume_gallons] > rect[:volume_gallons]
  end

  test "cylinder volume calculation" do
    result = Pets::FishTankCalculator.new(length: 18, width: 18, height: 24, tank_shape: "cylinder").call
    assert result[:valid]
    assert result[:volume_gallons] > 0
  end

  test "hexagonal volume calculation" do
    result = Pets::FishTankCalculator.new(length: 18, width: 18, height: 24, tank_shape: "hexagonal").call
    assert result[:valid]
    assert result[:volume_gallons] > 0
  end

  # --- Stocking levels ---

  test "calculates stocking percentage" do
    result = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16, fish_count: 10, avg_fish_inches: 1.5).call
    assert result[:valid]
    assert result[:stocking_percentage] > 0
  end

  test "under-stocked with few fish" do
    result = Pets::FishTankCalculator.new(length: 48, width: 24, height: 20, fish_count: 2, avg_fish_inches: 2).call
    assert result[:valid]
    assert_equal "Under-stocked", result[:stocking_level]
  end

  test "over-stocked with many fish" do
    result = Pets::FishTankCalculator.new(length: 12, width: 6, height: 8, fish_count: 20, avg_fish_inches: 3).call
    assert result[:valid]
    assert_equal "Over-stocked", result[:stocking_level]
  end

  # --- Equipment recommendations ---

  test "filter GPH is 4x tank volume" do
    result = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16).call
    assert result[:valid]
    expected_gph = (result[:volume_gallons] * 4).ceil
    assert_equal expected_gph, result[:recommended_filter_gph]
  end

  test "heater watts is 5x tank volume" do
    result = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16).call
    assert result[:valid]
    expected_watts = (result[:volume_gallons] * 5).ceil
    assert_equal expected_watts, result[:recommended_heater_watts]
  end

  # --- Validation ---

  test "zero length returns error" do
    result = Pets::FishTankCalculator.new(length: 0, width: 12, height: 16).call
    refute result[:valid]
    assert_includes result[:errors], "Length must be positive"
  end

  test "zero width returns error" do
    result = Pets::FishTankCalculator.new(length: 24, width: 0, height: 16).call
    refute result[:valid]
    assert_includes result[:errors], "Width must be positive"
  end

  test "zero height returns error" do
    result = Pets::FishTankCalculator.new(length: 24, width: 12, height: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  test "invalid tank shape returns error" do
    result = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16, tank_shape: "triangle").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Tank shape") }
  end

  test "negative fish count returns error" do
    result = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16, fish_count: -1).call
    refute result[:valid]
    assert_includes result[:errors], "Fish count cannot be negative"
  end

  test "unrealistic dimensions return error" do
    result = Pets::FishTankCalculator.new(length: 200, width: 12, height: 16).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("unrealistically large") }
  end

  test "errors accessor returns empty array before call" do
    calc = Pets::FishTankCalculator.new(length: 24, width: 12, height: 16)
    assert_equal [], calc.errors
  end
end
