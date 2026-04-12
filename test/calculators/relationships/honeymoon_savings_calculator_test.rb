require "test_helper"

class Relationships::HoneymoonSavingsCalculatorTest < ActiveSupport::TestCase
  test "5000 target with 500 saved over 12 months" do
    result = Relationships::HoneymoonSavingsCalculator.new(
      target_cost: 5000, current_savings: 500, months_available: 12
    ).call
    assert result[:valid]
    assert_in_delta 4500, result[:gap], 0.01
    assert_in_delta 375, result[:monthly_needed], 0.01
  end

  test "already saved enough flags on track" do
    result = Relationships::HoneymoonSavingsCalculator.new(
      target_cost: 5000, current_savings: 6000, months_available: 12
    ).call
    assert result[:valid]
    assert_equal 0, result[:gap]
    assert_equal true, result[:on_track]
  end

  test "zero months errors" do
    result = Relationships::HoneymoonSavingsCalculator.new(
      target_cost: 5000, current_savings: 0, months_available: 0
    ).call
    assert_equal false, result[:valid]
  end
end
