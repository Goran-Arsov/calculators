require "test_helper"

class Everyday::WordsPerMinuteCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "450 words in 10 minutes = 45 WPM" do
    result = Everyday::WordsPerMinuteCalculator.new(word_count: 450, time_minutes: 10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 45.0, result[:wpm]
  end

  test "characters per minute is WPM times 5" do
    result = Everyday::WordsPerMinuteCalculator.new(word_count: 400, time_minutes: 10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 40.0, result[:wpm]
    assert_equal 200, result[:characters_per_minute]
  end

  test "total minutes calculated from minutes and seconds" do
    result = Everyday::WordsPerMinuteCalculator.new(word_count: 100, time_minutes: 1, time_seconds: 30).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1.5, result[:total_minutes]
    assert_in_delta 66.7, result[:wpm], 0.1
  end

  test "seconds only (no minutes)" do
    result = Everyday::WordsPerMinuteCalculator.new(word_count: 50, time_minutes: 0, time_seconds: 30).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0.5, result[:total_minutes]
    assert_equal 100.0, result[:wpm]
  end

  test "estimates for common document lengths" do
    result = Everyday::WordsPerMinuteCalculator.new(word_count: 200, time_minutes: 5).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 40.0, result[:wpm]
    # email at 200 words / 40 WPM = 5.0 min
    assert_equal 5.0, result[:estimates]["email"][:type_minutes]
  end

  # --- Validation errors ---

  test "error when word count is zero" do
    result = Everyday::WordsPerMinuteCalculator.new(word_count: 0, time_minutes: 5).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Word count must be greater than zero"
  end

  test "error when total time is zero" do
    result = Everyday::WordsPerMinuteCalculator.new(word_count: 100, time_minutes: 0, time_seconds: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Total time must be greater than zero"
  end

  test "error when word count is negative" do
    result = Everyday::WordsPerMinuteCalculator.new(word_count: -50, time_minutes: 5).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Word count must be greater than zero"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::WordsPerMinuteCalculator.new(word_count: "450", time_minutes: "10", time_seconds: "0").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 45.0, result[:wpm]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::WordsPerMinuteCalculator.new(word_count: 100, time_minutes: 5)
    assert_equal [], calc.errors
  end

  test "very fast typing speed" do
    result = Everyday::WordsPerMinuteCalculator.new(word_count: 200, time_minutes: 1).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 200.0, result[:wpm]
    assert_equal 1000, result[:characters_per_minute]
  end

  test "estimates include read_minutes using average reading WPM" do
    result = Everyday::WordsPerMinuteCalculator.new(word_count: 238, time_minutes: 1).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # blog_post at 1500 words / 238 reading WPM = ~6.3 min
    assert_in_delta 6.3, result[:estimates]["blog_post"][:read_minutes], 0.1
  end
end
