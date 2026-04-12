require "test_helper"

class Photography::GoldenHourCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "New York summer solstice returns valid sunrise and sunset" do
    result = Photography::GoldenHourCalculator.new(
      latitude: 40.7128, longitude: -74.0060, date: "2024-06-21", timezone_offset: -4
    ).call
    assert_equal true, result[:valid]
    assert_not_equal "N/A", result[:sunrise]
    assert_not_equal "N/A", result[:sunset]
  end

  test "sunrise is before sunset" do
    result = Photography::GoldenHourCalculator.new(
      latitude: 40.7128, longitude: -74.0060, date: "2024-06-21", timezone_offset: -4
    ).call
    assert_equal true, result[:valid]
    # Parse times to compare
    sunrise_parts = result[:sunrise].split(":").map(&:to_i)
    sunset_parts = result[:sunset].split(":").map(&:to_i)
    sunrise_minutes = sunrise_parts[0] * 60 + sunrise_parts[1]
    sunset_minutes = sunset_parts[0] * 60 + sunset_parts[1]
    assert sunrise_minutes < sunset_minutes
  end

  test "golden hour periods are returned" do
    result = Photography::GoldenHourCalculator.new(
      latitude: 40.7128, longitude: -74.0060, date: "2024-06-21", timezone_offset: -4
    ).call
    assert_equal true, result[:valid]
    assert result[:morning_golden_hour].is_a?(Hash)
    assert result[:evening_golden_hour].is_a?(Hash)
    assert_not_equal "N/A", result[:morning_golden_hour][:start]
    assert_not_equal "N/A", result[:evening_golden_hour][:end]
  end

  test "blue hour periods are returned" do
    result = Photography::GoldenHourCalculator.new(
      latitude: 40.7128, longitude: -74.0060, date: "2024-06-21", timezone_offset: -4
    ).call
    assert_equal true, result[:valid]
    assert result[:morning_blue_hour].is_a?(Hash)
    assert result[:evening_blue_hour].is_a?(Hash)
  end

  test "day length is returned" do
    result = Photography::GoldenHourCalculator.new(
      latitude: 40.7128, longitude: -74.0060, date: "2024-06-21", timezone_offset: -4
    ).call
    assert_equal true, result[:valid]
    assert_not_equal "N/A", result[:day_length]
  end

  test "equator location returns results" do
    result = Photography::GoldenHourCalculator.new(
      latitude: 0, longitude: 0, date: "2024-03-20", timezone_offset: 0
    ).call
    assert_equal true, result[:valid]
    assert_not_equal "N/A", result[:sunrise]
  end

  test "solar noon is returned" do
    result = Photography::GoldenHourCalculator.new(
      latitude: 51.5074, longitude: -0.1278, date: "2024-06-21", timezone_offset: 1
    ).call
    assert_equal true, result[:valid]
    assert_not_equal "N/A", result[:solar_noon]
  end

  # --- Validation errors ---

  test "error when latitude out of range" do
    result = Photography::GoldenHourCalculator.new(
      latitude: 91, longitude: 0, date: "2024-06-21"
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Latitude") }
  end

  test "error when longitude out of range" do
    result = Photography::GoldenHourCalculator.new(
      latitude: 0, longitude: 181, date: "2024-06-21"
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Longitude") }
  end

  test "error when timezone offset out of range" do
    result = Photography::GoldenHourCalculator.new(
      latitude: 0, longitude: 0, date: "2024-06-21", timezone_offset: 15
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Timezone") }
  end

  test "errors accessor returns empty array before call" do
    calc = Photography::GoldenHourCalculator.new(
      latitude: 40.7128, longitude: -74.0060, date: "2024-06-21"
    )
    assert_equal [], calc.errors
  end
end
