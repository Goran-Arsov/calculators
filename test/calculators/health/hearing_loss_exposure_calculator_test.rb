require "test_helper"

class Health::HearingLossExposureCalculatorTest < ActiveSupport::TestCase
  # --- NIOSH at 85 dB ---

  test "NIOSH safe time at 85 dB is 8 hours" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 85).call
    assert result[:valid]
    assert_in_delta 8.0, result[:niosh][:safe_hours], 0.01
  end

  test "NIOSH safe time at 88 dB is 4 hours" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 88).call
    assert result[:valid]
    assert_in_delta 4.0, result[:niosh][:safe_hours], 0.01
  end

  test "NIOSH safe time at 91 dB is 2 hours" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 91).call
    assert result[:valid]
    assert_in_delta 2.0, result[:niosh][:safe_hours], 0.01
  end

  test "NIOSH safe time at 100 dB is about 15 minutes" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 100).call
    assert result[:valid]
    assert_in_delta 0.25, result[:niosh][:safe_hours], 0.02
  end

  # --- OSHA at 90 dB ---

  test "OSHA safe time at 90 dB is 8 hours" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 90).call
    assert result[:valid]
    assert_in_delta 8.0, result[:osha][:safe_hours], 0.01
  end

  test "OSHA safe time at 95 dB is 4 hours" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 95).call
    assert result[:valid]
    assert_in_delta 4.0, result[:osha][:safe_hours], 0.01
  end

  # --- Below threshold is unlimited ---

  test "NIOSH below 85 dB is unlimited" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 70).call
    assert result[:valid]
    assert_equal Float::INFINITY, result[:niosh][:safe_hours]
  end

  test "OSHA below 90 dB is unlimited" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 85).call
    assert result[:valid]
    assert_equal Float::INFINITY, result[:osha][:safe_hours]
  end

  # --- Dose calculation ---

  test "8 hours at 85 dB gives 100% NIOSH dose" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 85, exposure_hours: 8).call
    assert result[:valid]
    assert_in_delta 100.0, result[:niosh][:dose_percent], 0.5
    refute result[:niosh][:over_limit]
  end

  test "4 hours at 88 dB gives 100% NIOSH dose" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 88, exposure_hours: 4).call
    assert result[:valid]
    assert_in_delta 100.0, result[:niosh][:dose_percent], 0.5
  end

  test "8 hours at 88 dB gives 200% NIOSH dose" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 88, exposure_hours: 8).call
    assert result[:valid]
    assert_in_delta 200.0, result[:niosh][:dose_percent], 0.5
    assert result[:niosh][:over_limit]
  end

  # --- Risk levels ---

  test "60 dB is safe risk level" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 60).call
    assert_includes result[:risk_level], "Safe"
  end

  test "95 dB is moderate risk level" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 95).call
    assert_includes result[:risk_level], "Moderate"
  end

  test "125 dB is extreme risk level" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 125).call
    assert_includes result[:risk_level], "Extreme"
  end

  # --- Sound references ---

  test "sound references are included" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 85).call
    assert result[:sound_references].length > 0
  end

  # --- Formatted duration ---

  test "safe_formatted at 85 dB shows 8h" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 85).call
    assert_equal "8h", result[:niosh][:safe_formatted]
  end

  # --- Validation ---

  test "zero decibel returns error" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Decibel level must be positive"
  end

  test "over 200 dB returns error" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 250).call
    refute result[:valid]
    assert_includes result[:errors], "Decibel level seems unrealistic (max 200 dB)"
  end

  test "negative exposure hours returns error" do
    result = Health::HearingLossExposureCalculator.new(decibel_level: 85, exposure_hours: -1).call
    refute result[:valid]
    assert_includes result[:errors], "Exposure hours must be zero or positive"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::HearingLossExposureCalculator.new(decibel_level: 85)
    assert_equal [], calc.errors
  end
end
