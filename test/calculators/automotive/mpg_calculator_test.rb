require "test_helper"

class Automotive::MpgCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: imperial ---

  test "happy path imperial: 300 miles on 10 gallons = 30 MPG" do
    result = Automotive::MpgCalculator.new(distance: 300, fuel_used: 10).call
    assert result[:valid]
    assert_in_delta 30.0, result[:mpg], 0.1
    assert_in_delta 7.84, result[:liters_per_100km_equivalent], 0.1
  end

  test "happy path imperial: 450 miles on 15 gallons = 30 MPG" do
    result = Automotive::MpgCalculator.new(distance: 450, fuel_used: 15).call
    assert result[:valid]
    assert_in_delta 30.0, result[:mpg], 0.1
  end

  # --- Happy path: metric ---

  test "happy path metric: 500 km on 40 liters = 8 L/100km" do
    result = Automotive::MpgCalculator.new(distance: 500, fuel_used: 40, unit_system: "metric").call
    assert result[:valid]
    assert_in_delta 8.0, result[:liters_per_100km], 0.1
    assert_in_delta 12.5, result[:km_per_liter], 0.1
    assert_in_delta 29.4, result[:mpg_equivalent], 0.5
  end

  # --- Zero distance ---

  test "zero distance returns error" do
    result = Automotive::MpgCalculator.new(distance: 0, fuel_used: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Distance must be positive"
  end

  # --- Zero fuel ---

  test "zero fuel returns error" do
    result = Automotive::MpgCalculator.new(distance: 300, fuel_used: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Fuel used must be positive"
  end

  # --- Negative values ---

  test "negative distance returns error" do
    result = Automotive::MpgCalculator.new(distance: -100, fuel_used: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Distance must be positive"
  end

  test "negative fuel returns error" do
    result = Automotive::MpgCalculator.new(distance: 300, fuel_used: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Fuel used must be positive"
  end

  # --- Invalid unit system ---

  test "invalid unit system returns error" do
    result = Automotive::MpgCalculator.new(distance: 300, fuel_used: 10, unit_system: "invalid").call
    refute result[:valid]
    assert_includes result[:errors], "Unit system must be imperial or metric"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Automotive::MpgCalculator.new(distance: "300", fuel_used: "10").call
    assert result[:valid]
    assert_in_delta 30.0, result[:mpg], 0.1
  end

  # --- Large values ---

  test "very large distance computes correctly" do
    result = Automotive::MpgCalculator.new(distance: 100_000, fuel_used: 3000).call
    assert result[:valid]
    assert_in_delta 33.3, result[:mpg], 0.1
  end
end
