require "test_helper"

class Automotive::TowingCapacityCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: standard truck towing" do
    result = Automotive::TowingCapacityCalculator.new(
      gvwr: 7000, curb_weight: 5000,
      passengers_weight: 400, cargo_weight: 200,
      tongue_weight_pct: 10
    ).call
    assert result[:valid]
    assert_equal 2000, result[:max_payload].to_i
    assert_equal 600, result[:current_payload].to_i
    assert_equal 1400, result[:remaining_payload].to_i
    assert_equal 14_000, result[:max_towing_capacity].to_i
    assert_equal 11_200, result[:safe_towing_capacity].to_i
    assert_in_delta 30.0, result[:payload_utilization_pct], 0.1
  end

  # --- No passengers or cargo ---

  test "no passengers or cargo maximizes towing" do
    result = Automotive::TowingCapacityCalculator.new(
      gvwr: 7000, curb_weight: 5000,
      passengers_weight: 0, cargo_weight: 0,
      tongue_weight_pct: 10
    ).call
    assert result[:valid]
    assert_equal 20_000, result[:max_towing_capacity].to_i
    assert_in_delta 0.0, result[:payload_utilization_pct], 0.1
  end

  # --- Heavy payload limits towing ---

  test "heavy payload reduces towing capacity" do
    result = Automotive::TowingCapacityCalculator.new(
      gvwr: 7000, curb_weight: 5000,
      passengers_weight: 800, cargo_weight: 800,
      tongue_weight_pct: 10
    ).call
    assert result[:valid]
    assert_equal 400, result[:remaining_payload].to_i
    assert_equal 4_000, result[:max_towing_capacity].to_i
  end

  # --- Validation errors ---

  test "zero GVWR returns error" do
    result = Automotive::TowingCapacityCalculator.new(
      gvwr: 0, curb_weight: 5000
    ).call
    refute result[:valid]
    assert_includes result[:errors], "GVWR must be positive"
  end

  test "curb weight exceeds GVWR returns error" do
    result = Automotive::TowingCapacityCalculator.new(
      gvwr: 5000, curb_weight: 5000
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Curb weight cannot exceed GVWR"
  end

  test "negative passengers weight returns error" do
    result = Automotive::TowingCapacityCalculator.new(
      gvwr: 7000, curb_weight: 5000,
      passengers_weight: -200
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Passengers weight cannot be negative"
  end

  test "tongue weight pct out of range returns error" do
    result = Automotive::TowingCapacityCalculator.new(
      gvwr: 7000, curb_weight: 5000,
      tongue_weight_pct: 30
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Tongue weight percentage must be between 1 and 25"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Automotive::TowingCapacityCalculator.new(
      gvwr: "7000", curb_weight: "5000",
      passengers_weight: "400", cargo_weight: "200"
    ).call
    assert result[:valid]
  end
end
