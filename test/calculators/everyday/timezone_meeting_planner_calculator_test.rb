require "test_helper"

class Everyday::TimezoneMeetingPlannerCalculatorTest < ActiveSupport::TestCase
  test "finds overlap between EST and CET" do
    result = Everyday::TimezoneMeetingPlannerCalculator.new(timezones: %w[EST CET]).call
    assert_equal true, result[:valid]
    assert result[:overlap_count] > 0
    assert_equal true, result[:has_overlap]
  end

  test "returns 24-hour schedule" do
    result = Everyday::TimezoneMeetingPlannerCalculator.new(timezones: %w[UTC GMT]).call
    assert_equal true, result[:valid]
    assert_equal 24, result[:schedule].size
  end

  test "UTC and GMT are identical" do
    result = Everyday::TimezoneMeetingPlannerCalculator.new(timezones: %w[UTC GMT]).call
    assert_equal true, result[:valid]
    # All business hours overlap since they have the same offset
    assert_equal 8, result[:overlap_count] # 9-17 = 8 hours
  end

  test "custom business hours" do
    result = Everyday::TimezoneMeetingPlannerCalculator.new(
      timezones: %w[UTC GMT], business_start: 8, business_end: 20
    ).call
    assert_equal true, result[:valid]
    assert_equal 12, result[:overlap_count]
  end

  test "handles string input" do
    result = Everyday::TimezoneMeetingPlannerCalculator.new(timezones: "EST, PST").call
    assert_equal true, result[:valid]
    assert_equal 2, result[:timezones].size
  end

  test "error when fewer than two timezones" do
    result = Everyday::TimezoneMeetingPlannerCalculator.new(timezones: ["EST"]).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least two timezones are required"
  end

  test "error for unknown timezone" do
    result = Everyday::TimezoneMeetingPlannerCalculator.new(timezones: %w[EST INVALID]).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown timezones") }
  end

  test "error when business end is before start" do
    result = Everyday::TimezoneMeetingPlannerCalculator.new(timezones: %w[EST CET], business_start: 17, business_end: 9).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Business end must be after business start"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::TimezoneMeetingPlannerCalculator.new(timezones: %w[EST CET])
    assert_equal [], calc.errors
  end
end
