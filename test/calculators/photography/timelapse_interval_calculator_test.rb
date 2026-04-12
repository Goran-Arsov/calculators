require "test_helper"

class Photography::TimelapseIntervalCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "120 min event to 30s video at 24fps" do
    result = Photography::TimelapseIntervalCalculator.new(
      event_duration_minutes: 120, final_video_seconds: 30, playback_fps: 24
    ).call
    assert_equal true, result[:valid]
    assert_equal 720, result[:total_frames]
    assert_in_delta 10.0, result[:interval_seconds], 0.1  # 7200/720 = 10
  end

  test "speed factor is calculated correctly" do
    result = Photography::TimelapseIntervalCalculator.new(
      event_duration_minutes: 60, final_video_seconds: 30, playback_fps: 24
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 120.0, result[:speed_factor], 0.1  # 3600/30 = 120x
  end

  test "storage estimates are positive" do
    result = Photography::TimelapseIntervalCalculator.new(
      event_duration_minutes: 60, final_video_seconds: 30, playback_fps: 24
    ).call
    assert_equal true, result[:valid]
    assert result[:estimated_storage_jpeg_gb] > 0
    assert result[:estimated_storage_raw_gb] > 0
    assert result[:estimated_storage_raw_gb] > result[:estimated_storage_jpeg_gb]
  end

  test "duration display formats correctly" do
    result = Photography::TimelapseIntervalCalculator.new(
      event_duration_minutes: 120, final_video_seconds: 30, playback_fps: 24
    ).call
    assert_equal true, result[:valid]
    assert result[:event_duration_display].include?("h")
    assert_equal "30s", result[:final_video_display]
  end

  test "30fps playback produces more frames" do
    result_24 = Photography::TimelapseIntervalCalculator.new(
      event_duration_minutes: 60, final_video_seconds: 30, playback_fps: 24
    ).call
    result_30 = Photography::TimelapseIntervalCalculator.new(
      event_duration_minutes: 60, final_video_seconds: 30, playback_fps: 30
    ).call

    assert result_30[:total_frames] > result_24[:total_frames]
  end

  # --- Validation errors ---

  test "error when event duration is zero" do
    result = Photography::TimelapseIntervalCalculator.new(
      event_duration_minutes: 0, final_video_seconds: 30, playback_fps: 24
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Event duration must be positive"
  end

  test "error when final video length is zero" do
    result = Photography::TimelapseIntervalCalculator.new(
      event_duration_minutes: 60, final_video_seconds: 0, playback_fps: 24
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Final video length must be positive"
  end

  test "error when FPS is zero" do
    result = Photography::TimelapseIntervalCalculator.new(
      event_duration_minutes: 60, final_video_seconds: 30, playback_fps: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Playback FPS must be positive"
  end

  test "error when event exceeds maximum duration" do
    result = Photography::TimelapseIntervalCalculator.new(
      event_duration_minutes: 200 * 60, final_video_seconds: 30, playback_fps: 24
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("168") }
  end

  test "errors accessor returns empty array before call" do
    calc = Photography::TimelapseIntervalCalculator.new(
      event_duration_minutes: 120, final_video_seconds: 30
    )
    assert_equal [], calc.errors
  end
end
