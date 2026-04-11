require "test_helper"

class Geography::HikingTimeCalculatorTest < ActiveSupport::TestCase
  test "10 km flat normal pace is 2 hours" do
    result = Geography::HikingTimeCalculator.new(
      distance_km: 10, ascent_m: 0, descent_m: 0, fitness: "normal"
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 2.0, result[:total_hours], 0.001
    assert_equal 120, result[:total_minutes]
    assert_equal "2h 0m", result[:formatted_time]
  end

  test "5 km flat with 600m ascent is 2 hours (Naismith)" do
    result = Geography::HikingTimeCalculator.new(
      distance_km: 5, ascent_m: 600, descent_m: 0, fitness: "normal"
    ).call
    assert_in_delta 2.0, result[:total_hours], 0.001
  end

  test "fast fitness multiplier is 0.80" do
    fast = Geography::HikingTimeCalculator.new(
      distance_km: 10, ascent_m: 0, descent_m: 0, fitness: "fast"
    ).call
    normal = Geography::HikingTimeCalculator.new(
      distance_km: 10, ascent_m: 0, descent_m: 0, fitness: "normal"
    ).call
    assert_in_delta normal[:total_hours] * 0.80, fast[:total_hours], 0.001
  end

  test "slow fitness multiplier is 1.50" do
    slow = Geography::HikingTimeCalculator.new(
      distance_km: 10, ascent_m: 0, descent_m: 0, fitness: "slow"
    ).call
    assert_in_delta 3.0, slow[:total_hours], 0.001
  end

  test "descent adds time via Langmuir correction" do
    no_descent = Geography::HikingTimeCalculator.new(
      distance_km: 10, ascent_m: 0, descent_m: 0, fitness: "normal"
    ).call
    with_descent = Geography::HikingTimeCalculator.new(
      distance_km: 10, ascent_m: 0, descent_m: 900, fitness: "normal"
    ).call
    assert with_descent[:total_hours] > no_descent[:total_hours]
  end

  test "zero distance returns errors" do
    result = Geography::HikingTimeCalculator.new(
      distance_km: 0, ascent_m: 100, fitness: "normal"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Distance must be greater than zero"
  end

  test "invalid fitness returns errors" do
    result = Geography::HikingTimeCalculator.new(
      distance_km: 10, fitness: "ultra"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Fitness must be one of: fast, normal, moderate, slow"
  end
end
