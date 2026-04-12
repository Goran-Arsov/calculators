require "test_helper"

class Everyday::ApiRateLimitCalculatorTest < ActiveSupport::TestCase
  test "calculates rates from 1000 requests per hour" do
    result = Everyday::ApiRateLimitCalculator.new(rate_limit: 1000, window_seconds: 3600).call
    assert_equal true, result[:valid]
    assert_in_delta 0.2778, result[:requests_per_second], 0.001
    assert_in_delta 16.67, result[:requests_per_minute], 0.01
    assert_in_delta 1000.0, result[:requests_per_hour], 0.01
  end

  test "calculates remaining from current usage" do
    result = Everyday::ApiRateLimitCalculator.new(rate_limit: 100, window_seconds: 60, current_usage: 75).call
    assert_equal true, result[:valid]
    assert_equal 25, result[:remaining]
    assert_equal 75.0, result[:usage_percent]
  end

  test "remaining is zero when usage exceeds limit" do
    result = Everyday::ApiRateLimitCalculator.new(rate_limit: 100, window_seconds: 60, current_usage: 150).call
    assert_equal true, result[:valid]
    assert_equal 0, result[:remaining]
    assert_equal 60, result[:time_until_reset]
  end

  test "safe rate is 80% of max" do
    result = Everyday::ApiRateLimitCalculator.new(rate_limit: 100, window_seconds: 100).call
    assert_equal true, result[:valid]
    assert_in_delta 0.8, result[:safe_requests_per_second], 0.001
  end

  test "includes burst limit info when provided" do
    result = Everyday::ApiRateLimitCalculator.new(rate_limit: 100, window_seconds: 60, burst_limit: 20).call
    assert_equal true, result[:valid]
    assert_equal 20, result[:burst_limit]
    assert_in_delta 0.2, result[:burst_ratio], 0.01
  end

  test "error when rate limit is zero" do
    result = Everyday::ApiRateLimitCalculator.new(rate_limit: 0, window_seconds: 60).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Rate limit must be greater than zero"
  end

  test "error when window is zero" do
    result = Everyday::ApiRateLimitCalculator.new(rate_limit: 100, window_seconds: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Window must be greater than zero"
  end

  test "error when current usage is negative" do
    result = Everyday::ApiRateLimitCalculator.new(rate_limit: 100, window_seconds: 60, current_usage: -1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Current usage cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::ApiRateLimitCalculator.new(rate_limit: 100, window_seconds: 60)
    assert_equal [], calc.errors
  end
end
