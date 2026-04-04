require "test_helper"

class Finance::RoiCalculatorTest < ActiveSupport::TestCase
  # --- Solve for ROI ---

  test "ROI from gain and cost: gain=150, cost=100 → ROI=50%" do
    result = Finance::RoiCalculator.new(gain: 150, cost: 100).call
    assert result[:valid]
    assert_equal 50.0, result[:roi]
    assert_equal :roi, result[:solved_for]
  end

  test "ROI from gain and cost: gain=200, cost=200 → ROI=0%" do
    result = Finance::RoiCalculator.new(gain: 200, cost: 200).call
    assert result[:valid]
    assert_equal 0.0, result[:roi]
  end

  test "negative ROI when gain is less than cost" do
    result = Finance::RoiCalculator.new(gain: 80, cost: 100).call
    assert result[:valid]
    assert_equal(-20.0, result[:roi])
  end

  # --- Solve for gain ---

  test "solve for gain: ROI=50%, cost=100 → gain=150" do
    result = Finance::RoiCalculator.new(roi: 50, cost: 100).call
    assert result[:valid]
    assert_equal 150.0, result[:gain]
    assert_equal :gain, result[:solved_for]
  end

  # --- Solve for cost ---

  test "solve for cost: gain=150, ROI=50% → cost=100" do
    result = Finance::RoiCalculator.new(gain: 150, roi: 50).call
    assert result[:valid]
    assert_equal 100.0, result[:cost]
    assert_equal :cost, result[:solved_for]
  end

  # --- Validation errors ---

  test "error when fewer than 2 values provided" do
    result = Finance::RoiCalculator.new(gain: 100).call
    refute result[:valid]
    assert_includes result[:errors], "Exactly 2 of gain, cost, and roi must be provided"
  end

  test "error when cost is zero" do
    result = Finance::RoiCalculator.new(gain: 100, cost: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Cost must not be zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::RoiCalculator.new(gain: 150, cost: 100)
    assert_equal [], calc.errors
  end
end
