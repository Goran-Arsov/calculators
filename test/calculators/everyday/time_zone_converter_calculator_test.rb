require "test_helper"

class Everyday::TimeZoneConverterCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "EST to PST: 12:00 → 09:00, offset -3" do
    result = Everyday::TimeZoneConverterCalculator.new(hour: 12, minute: 0, source_zone: "EST", target_zone: "PST").call
    assert_nil result[:errors]
    assert_equal 9, result[:converted_hour]
    assert_equal 0, result[:converted_minute]
    assert_equal(-3, result[:offset_diff])
    assert_equal 0, result[:day_shift]
  end

  test "PST to JST: 10:30 → 03:30 next day" do
    result = Everyday::TimeZoneConverterCalculator.new(hour: 10, minute: 30, source_zone: "PST", target_zone: "JST").call
    assert_nil result[:errors]
    assert_equal 3, result[:converted_hour]
    assert_equal 30, result[:converted_minute]
    assert_equal 1, result[:day_shift]
  end

  test "JST to PST: 02:00 → 09:00 previous day" do
    result = Everyday::TimeZoneConverterCalculator.new(hour: 2, minute: 0, source_zone: "JST", target_zone: "PST").call
    assert_nil result[:errors]
    assert_equal 9, result[:converted_hour]
    assert_equal 0, result[:converted_minute]
    assert_equal(-1, result[:day_shift])
  end

  test "same timezone returns same time" do
    result = Everyday::TimeZoneConverterCalculator.new(hour: 15, minute: 45, source_zone: "UTC", target_zone: "UTC").call
    assert_nil result[:errors]
    assert_equal 15, result[:converted_hour]
    assert_equal 45, result[:converted_minute]
    assert_equal 0, result[:day_shift]
  end

  test "IST half-hour offset: UTC 12:00 → IST 17:30" do
    result = Everyday::TimeZoneConverterCalculator.new(hour: 12, minute: 0, source_zone: "UTC", target_zone: "IST").call
    assert_nil result[:errors]
    assert_equal 17, result[:converted_hour]
    assert_equal 30, result[:converted_minute]
  end

  test "formatted_time is zero-padded" do
    result = Everyday::TimeZoneConverterCalculator.new(hour: 0, minute: 0, source_zone: "UTC", target_zone: "CET").call
    assert_nil result[:errors]
    assert_equal "01:00", result[:formatted_time]
  end

  # --- Validation errors ---

  test "error for invalid hour" do
    result = Everyday::TimeZoneConverterCalculator.new(hour: 25, minute: 0, source_zone: "UTC", target_zone: "EST").call
    assert result[:errors].any?
    assert_includes result[:errors], "Hour must be between 0 and 23"
  end

  test "error for invalid minute" do
    result = Everyday::TimeZoneConverterCalculator.new(hour: 12, minute: 61, source_zone: "UTC", target_zone: "EST").call
    assert result[:errors].any?
    assert_includes result[:errors], "Minute must be between 0 and 59"
  end

  test "error for unknown source timezone" do
    result = Everyday::TimeZoneConverterCalculator.new(hour: 12, minute: 0, source_zone: "XYZ", target_zone: "EST").call
    assert result[:errors].any?
    assert result[:errors].any? { |e| e.include?("Unknown source timezone") }
  end

  test "error for unknown target timezone" do
    result = Everyday::TimeZoneConverterCalculator.new(hour: 12, minute: 0, source_zone: "UTC", target_zone: "FAKE").call
    assert result[:errors].any?
    assert result[:errors].any? { |e| e.include?("Unknown target timezone") }
  end

  test "string coercion for hour and minute" do
    result = Everyday::TimeZoneConverterCalculator.new(hour: "14", minute: "30", source_zone: "UTC", target_zone: "EST").call
    assert_nil result[:errors]
    assert_equal 9, result[:converted_hour]
    assert_equal 30, result[:converted_minute]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::TimeZoneConverterCalculator.new(hour: 12, minute: 0, source_zone: "UTC", target_zone: "EST")
    assert_equal [], calc.errors
  end
end
