require "test_helper"

class Everyday::StopwatchCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "formats elapsed milliseconds into HH:MM:SS.ms" do
    result = Everyday::StopwatchCalculator.new(elapsed_ms: 3661500).call

    assert result[:valid]
    assert_equal "01:01:01.500", result[:formatted_time]
  end

  test "returns total seconds" do
    result = Everyday::StopwatchCalculator.new(elapsed_ms: 5000).call

    assert result[:valid]
    assert_equal 5.0, result[:total_seconds]
  end

  test "returns total minutes" do
    result = Everyday::StopwatchCalculator.new(elapsed_ms: 120_000).call

    assert result[:valid]
    assert_equal 2.0, result[:total_minutes]
  end

  test "preserves elapsed_ms in result" do
    result = Everyday::StopwatchCalculator.new(elapsed_ms: 12345).call

    assert result[:valid]
    assert_equal 12345, result[:elapsed_ms]
  end

  # --- Formatting edge cases ---

  test "zero milliseconds" do
    result = Everyday::StopwatchCalculator.new(elapsed_ms: 0).call

    assert result[:valid]
    assert_equal "00:00:00.000", result[:formatted_time]
    assert_equal 0.0, result[:total_seconds]
    assert_equal 0.0, result[:total_minutes]
  end

  test "single millisecond" do
    result = Everyday::StopwatchCalculator.new(elapsed_ms: 1).call

    assert result[:valid]
    assert_equal "00:00:00.001", result[:formatted_time]
  end

  test "exactly one hour" do
    result = Everyday::StopwatchCalculator.new(elapsed_ms: 3_600_000).call

    assert result[:valid]
    assert_equal "01:00:00.000", result[:formatted_time]
    assert_equal 3600.0, result[:total_seconds]
    assert_equal 60.0, result[:total_minutes]
  end

  test "large elapsed time over 24 hours" do
    result = Everyday::StopwatchCalculator.new(elapsed_ms: 90_061_999).call

    assert result[:valid]
    assert_equal "25:01:01.999", result[:formatted_time]
  end

  # --- Validation ---

  test "negative elapsed_ms returns error" do
    result = Everyday::StopwatchCalculator.new(elapsed_ms: -1).call

    refute result[:valid]
    assert_includes result[:errors], "Elapsed time cannot be negative"
  end

  # --- String coercion ---

  test "string input is coerced to integer" do
    result = Everyday::StopwatchCalculator.new(elapsed_ms: "5000").call

    assert result[:valid]
    assert_equal 5.0, result[:total_seconds]
    assert_equal "00:00:05.000", result[:formatted_time]
  end

  test "empty string input treated as zero" do
    result = Everyday::StopwatchCalculator.new(elapsed_ms: "").call

    assert result[:valid]
    assert_equal "00:00:00.000", result[:formatted_time]
  end
end
