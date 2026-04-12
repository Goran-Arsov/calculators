require "test_helper"

class Photography::VideoFileSizeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "10 Mbps for 60 seconds produces correct file size" do
    result = Photography::VideoFileSizeCalculator.new(
      bitrate_mbps: 10, duration_seconds: 60, audio_bitrate_kbps: 0
    ).call
    assert_equal true, result[:valid]
    # 10 Mbps * 60s = 600,000,000 bits = 75,000,000 bytes / 1,048,576 = 71.5 MB
    assert_in_delta 71.5, result[:video_size_mb], 0.5
  end

  test "audio bitrate is included in total" do
    result = Photography::VideoFileSizeCalculator.new(
      bitrate_mbps: 10, duration_seconds: 60, audio_bitrate_kbps: 320
    ).call
    assert_equal true, result[:valid]
    assert result[:audio_size_mb] > 0
    assert result[:file_size_mb] > result[:video_size_mb]
  end

  test "total frames calculated correctly" do
    result = Photography::VideoFileSizeCalculator.new(
      bitrate_mbps: 50, duration_seconds: 10, frame_rate: 30
    ).call
    assert_equal true, result[:valid]
    assert_equal 300, result[:total_frames]
  end

  test "GB value is consistent with MB value" do
    result = Photography::VideoFileSizeCalculator.new(
      bitrate_mbps: 50, duration_seconds: 3600
    ).call
    assert_equal true, result[:valid]
    assert_in_delta result[:file_size_mb] / 1024.0, result[:file_size_gb], 0.1
  end

  test "codec name is returned" do
    result = Photography::VideoFileSizeCalculator.new(
      bitrate_mbps: 50, duration_seconds: 60, codec: "h265"
    ).call
    assert_equal true, result[:valid]
    assert_equal "H.265 (HEVC)", result[:codec_name]
  end

  test "duration display format for long videos" do
    result = Photography::VideoFileSizeCalculator.new(
      bitrate_mbps: 50, duration_seconds: 7200
    ).call
    assert_equal true, result[:valid]
    assert result[:duration_display].include?("h")
  end

  # --- Validation errors ---

  test "error when bitrate is zero" do
    result = Photography::VideoFileSizeCalculator.new(
      bitrate_mbps: 0, duration_seconds: 60
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Bitrate must be positive"
  end

  test "error when duration is zero" do
    result = Photography::VideoFileSizeCalculator.new(
      bitrate_mbps: 50, duration_seconds: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Duration must be positive"
  end

  test "error for unknown codec" do
    result = Photography::VideoFileSizeCalculator.new(
      bitrate_mbps: 50, duration_seconds: 60, codec: "invalid"
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("codec") }
  end

  test "errors accessor returns empty array before call" do
    calc = Photography::VideoFileSizeCalculator.new(
      bitrate_mbps: 50, duration_seconds: 60
    )
    assert_equal [], calc.errors
  end
end
