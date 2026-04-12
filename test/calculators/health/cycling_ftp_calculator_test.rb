require "test_helper"

class Health::CyclingFtpCalculatorTest < ActiveSupport::TestCase
  # --- Direct FTP ---

  test "direct FTP 250W returns 7 zones" do
    result = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 250).call
    assert result[:valid]
    assert_equal 250, result[:ftp]
    assert_equal 7, result[:zones].length
  end

  # --- 20-minute test ---

  test "twenty_minute test 270W gives FTP 256.5" do
    result = Health::CyclingFtpCalculator.new(mode: "twenty_minute", test_power: 270).call
    assert result[:valid]
    # 270 * 0.95 = 256.5 rounded to 257
    assert_equal 257, result[:ftp]
  end

  # --- 8-minute test ---

  test "eight_minute test 300W gives FTP 270" do
    result = Health::CyclingFtpCalculator.new(mode: "eight_minute", test_power: 300).call
    assert result[:valid]
    assert_equal 270, result[:ftp]
  end

  # --- Ramp test ---

  test "ramp test 400W gives FTP 300" do
    result = Health::CyclingFtpCalculator.new(mode: "ramp", test_power: 400).call
    assert result[:valid]
    assert_equal 300, result[:ftp]
  end

  # --- Zone calculations ---

  test "zone 1 is 0-55% FTP" do
    result = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 200).call
    zone1 = result[:zones].find { |z| z[:key] == :zone_1 }
    assert_equal 0, zone1[:min_watts]
    assert_equal 110, zone1[:max_watts]
  end

  test "zone 4 is 91-105% FTP" do
    result = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 200).call
    zone4 = result[:zones].find { |z| z[:key] == :zone_4 }
    assert_equal 182, zone4[:min_watts]
    assert_equal 210, zone4[:max_watts]
  end

  test "zone 7 has no upper limit" do
    result = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 200).call
    zone7 = result[:zones].find { |z| z[:key] == :zone_7 }
    assert_nil zone7[:max_watts]
    assert_equal 302, zone7[:min_watts]
  end

  # --- Watts per kg and rider category ---

  test "watts_per_kg calculated when weight provided" do
    result = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 250, weight: 70).call
    assert result[:valid]
    assert_in_delta 3.57, result[:watts_per_kg], 0.05
    assert_equal "Cat 3 / Strong", result[:rider_category]
  end

  test "lbs weight unit converted correctly" do
    result = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 250, weight: 154, weight_unit: "lbs").call
    assert result[:valid]
    assert_in_delta 69.85, result[:weight_kg], 0.5
  end

  test "world tour pro category above 5.5 w/kg" do
    result = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 400, weight: 70).call
    assert_equal "World Tour Pro", result[:rider_category]
  end

  test "beginner category below 2.0 w/kg" do
    result = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 100, weight: 80).call
    assert_equal "Beginner", result[:rider_category]
  end

  # --- No weight provided ---

  test "no weight skips watts_per_kg" do
    result = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 250).call
    assert result[:valid]
    refute result.key?(:watts_per_kg)
  end

  # --- Validation ---

  test "direct mode with zero FTP returns error" do
    result = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 0).call
    refute result[:valid]
    assert_includes result[:errors], "FTP must be positive"
  end

  test "FTP over 600 returns error" do
    result = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 650).call
    refute result[:valid]
    assert_includes result[:errors], "FTP seems unrealistically high (max 600W)"
  end

  test "test power over 800 returns error" do
    result = Health::CyclingFtpCalculator.new(mode: "twenty_minute", test_power: 850).call
    refute result[:valid]
    assert_includes result[:errors], "Test power seems unrealistically high (max 800W)"
  end

  test "invalid mode returns error" do
    result = Health::CyclingFtpCalculator.new(mode: "invalid", ftp: 250).call
    refute result[:valid]
    assert_includes result[:errors], "Mode must be direct, twenty_minute, eight_minute, or ramp"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::CyclingFtpCalculator.new(mode: "direct", ftp: 250)
    assert_equal [], calc.errors
  end
end
