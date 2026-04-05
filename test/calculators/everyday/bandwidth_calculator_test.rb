require "test_helper"

class Everyday::BandwidthCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "1 GB at 100 Mbps" do
    result = Everyday::BandwidthCalculator.new(file_size: 1, file_unit: "GB", speed: 100, speed_unit: "Mbps").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 1 GB = 1,073,741,824 bytes = 8,589,934,592 bits
    # 100 Mbps = 100,000,000 bps
    # Time = 8,589,934,592 / 100,000,000 = 85.90 seconds
    assert_in_delta 85.90, result[:download_seconds], 0.1
    assert_match(/1m/, result[:download_time])
  end

  test "100 MB at 10 Mbps" do
    result = Everyday::BandwidthCalculator.new(file_size: 100, file_unit: "MB", speed: 10, speed_unit: "Mbps").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 100 MB = 104,857,600 bytes = 838,860,800 bits
    # Time = 838,860,800 / 10,000,000 = 83.89 seconds
    assert_in_delta 83.89, result[:download_seconds], 0.1
  end

  test "1 KB at 1 Mbps" do
    result = Everyday::BandwidthCalculator.new(file_size: 1, file_unit: "KB", speed: 1, speed_unit: "Mbps").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 1 KB = 1024 bytes = 8192 bits, at 1,000,000 bps = 0.008192 seconds
    assert_in_delta 0.01, result[:download_seconds], 0.01
  end

  test "file_size_mb is calculated" do
    result = Everyday::BandwidthCalculator.new(file_size: 2, file_unit: "GB", speed: 50, speed_unit: "Mbps").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_in_delta 2048.0, result[:file_size_mb], 0.1
  end

  test "speed_mbps is calculated" do
    result = Everyday::BandwidthCalculator.new(file_size: 1, file_unit: "MB", speed: 500, speed_unit: "Kbps").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0.5, result[:speed_mbps]
  end

  test "speed_for_1_min is calculated" do
    result = Everyday::BandwidthCalculator.new(file_size: 1, file_unit: "GB", speed: 100, speed_unit: "Mbps").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 8,589,934,592 bits / 60 sec / 1,000,000 = ~143.17 Mbps
    assert_in_delta 143.17, result[:speed_for_1_min_mbps], 0.1
  end

  test "TB file size" do
    result = Everyday::BandwidthCalculator.new(file_size: 1, file_unit: "TB", speed: 1, speed_unit: "Gbps").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 1 TB = 1,099,511,627,776 bytes = 8,796,093,022,208 bits
    # 1 Gbps = 1,000,000,000 bps
    # Time = 8796.09 seconds
    assert_in_delta 8796.09, result[:download_seconds], 1.0
  end

  test "humanized time format" do
    result = Everyday::BandwidthCalculator.new(file_size: 1, file_unit: "GB", speed: 100, speed_unit: "Mbps").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_kind_of String, result[:download_time]
    assert result[:download_time].length > 0
  end

  # --- Validation errors ---

  test "error when file size is zero" do
    result = Everyday::BandwidthCalculator.new(file_size: 0, file_unit: "MB", speed: 10, speed_unit: "Mbps").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "File size must be greater than zero"
  end

  test "error when speed is zero" do
    result = Everyday::BandwidthCalculator.new(file_size: 100, file_unit: "MB", speed: 0, speed_unit: "Mbps").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Speed must be greater than zero"
  end

  test "error for unknown file unit" do
    result = Everyday::BandwidthCalculator.new(file_size: 100, file_unit: "PB", speed: 10, speed_unit: "Mbps").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown file size unit") }
  end

  test "error for unknown speed unit" do
    result = Everyday::BandwidthCalculator.new(file_size: 100, file_unit: "MB", speed: 10, speed_unit: "Tbps").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown speed unit") }
  end

  test "string coercion for file_size and speed" do
    result = Everyday::BandwidthCalculator.new(file_size: "100", file_unit: "MB", speed: "10", speed_unit: "Mbps").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_in_delta 83.89, result[:download_seconds], 0.1
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::BandwidthCalculator.new(file_size: 100, file_unit: "MB", speed: 10, speed_unit: "Mbps")
    assert_equal [], calc.errors
  end
end
