require "test_helper"

class Everyday::UnixTimestampCalculatorTest < ActiveSupport::TestCase
  test "converts timestamp to datetime" do
    result = Everyday::UnixTimestampCalculator.new(input: "0", mode: :to_datetime).call
    assert result[:valid]
    assert_equal 0, result[:unix_timestamp]
    assert_equal 0, result[:millisecond_timestamp]
    assert_equal "1970-01-01T00:00:00Z", result[:iso8601]
    assert_equal "1970-01-01", result[:date_only]
    assert_equal "00:00:00", result[:time_only]
    assert_equal "Thursday", result[:day_of_week]
    assert result[:is_past]
  end

  test "converts positive timestamp" do
    result = Everyday::UnixTimestampCalculator.new(input: "1609459200", mode: :to_datetime).call
    assert result[:valid]
    assert_equal 1609459200, result[:unix_timestamp]
    assert_equal "2021-01-01T00:00:00Z", result[:iso8601]
    assert_equal "2021-01-01", result[:date_only]
    assert_equal "Friday", result[:day_of_week]
  end

  test "converts negative timestamp for dates before 1970" do
    result = Everyday::UnixTimestampCalculator.new(input: "-86400", mode: :to_datetime).call
    assert result[:valid]
    assert_equal(-86400, result[:unix_timestamp])
    assert_equal "1969-12-31", result[:date_only]
    assert_equal "Wednesday", result[:day_of_week]
  end

  test "converts millisecond timestamp correctly" do
    result = Everyday::UnixTimestampCalculator.new(input: "1609459200", mode: :to_datetime).call
    assert result[:valid]
    assert_equal 1609459200000, result[:millisecond_timestamp]
  end

  test "converts datetime string to timestamp" do
    result = Everyday::UnixTimestampCalculator.new(input: "2021-01-01 00:00:00 UTC", mode: :to_timestamp).call
    assert result[:valid]
    assert_equal 1609459200, result[:unix_timestamp]
    assert_equal 1609459200000, result[:millisecond_timestamp]
  end

  test "converts ISO 8601 datetime to timestamp" do
    result = Everyday::UnixTimestampCalculator.new(input: "2021-01-01T00:00:00Z", mode: :to_timestamp).call
    assert result[:valid]
    assert_equal 1609459200, result[:unix_timestamp]
  end

  test "returns relative time description" do
    result = Everyday::UnixTimestampCalculator.new(input: "0", mode: :to_datetime).call
    assert result[:valid]
    assert_match(/ago/, result[:relative_time])
  end

  test "returns rfc2822 format" do
    result = Everyday::UnixTimestampCalculator.new(input: "1609459200", mode: :to_datetime).call
    assert result[:valid]
    assert_match(/Fri, 01 Jan 2021/, result[:rfc2822])
  end

  test "returns utc format" do
    result = Everyday::UnixTimestampCalculator.new(input: "1609459200", mode: :to_datetime).call
    assert result[:valid]
    assert_equal "2021-01-01 00:00:00 UTC", result[:utc]
  end

  test "returns error for empty input" do
    result = Everyday::UnixTimestampCalculator.new(input: "", mode: :to_datetime).call
    assert_not result[:valid]
    assert_includes result[:errors], "Input cannot be empty"
  end

  test "returns error for non-numeric timestamp" do
    result = Everyday::UnixTimestampCalculator.new(input: "abc", mode: :to_datetime).call
    assert_not result[:valid]
    assert_includes result[:errors], "Timestamp must be a valid integer or decimal number"
  end

  test "returns error for invalid datetime string" do
    result = Everyday::UnixTimestampCalculator.new(input: "not-a-date", mode: :to_timestamp).call
    assert_not result[:valid]
    assert_includes result[:errors], "Invalid datetime format. Use ISO 8601 or a standard datetime string"
  end

  test "returns error for invalid mode" do
    result = Everyday::UnixTimestampCalculator.new(input: "123", mode: :invalid).call
    assert_not result[:valid]
    assert_includes result[:errors], "Invalid mode. Use :to_datetime or :to_timestamp"
  end

  test "handles decimal timestamp" do
    result = Everyday::UnixTimestampCalculator.new(input: "1609459200.5", mode: :to_datetime).call
    assert result[:valid]
    assert_equal 1609459200, result[:unix_timestamp]
    assert_equal 1609459200500, result[:millisecond_timestamp]
  end

  test "handles whitespace in input" do
    result = Everyday::UnixTimestampCalculator.new(input: "  1609459200  ", mode: :to_datetime).call
    assert result[:valid]
    assert_equal 1609459200, result[:unix_timestamp]
  end

  test "handles very large timestamp" do
    result = Everyday::UnixTimestampCalculator.new(input: "4102444800", mode: :to_datetime).call
    assert result[:valid]
    assert_equal "2100-01-01", result[:date_only]
  end
end
