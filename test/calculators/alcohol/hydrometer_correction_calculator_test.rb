require "test_helper"

class Alcohol::HydrometerCorrectionCalculatorTest < ActiveSupport::TestCase
  test "no correction needed at calibration temperature" do
    result = Alcohol::HydrometerCorrectionCalculator.new(
      measured_gravity: 1.050, sample_temp_f: 60
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 1.050, result[:corrected_gravity], 0.0005
  end

  test "warm sample reads low so correction is positive" do
    result = Alcohol::HydrometerCorrectionCalculator.new(
      measured_gravity: 1.050, sample_temp_f: 80
    ).call
    assert result[:corrected_gravity] > 1.050
    assert result[:adjustment] > 0
    # ~+0.002 correction at 80°F
    assert_in_delta 0.002, result[:adjustment], 0.001
  end

  test "cool sample reads high so correction is negative" do
    result = Alcohol::HydrometerCorrectionCalculator.new(
      measured_gravity: 1.050, sample_temp_f: 50
    ).call
    assert result[:corrected_gravity] < 1.050
    assert result[:adjustment] < 0
  end

  test "celsius conversion of sample temp" do
    result = Alcohol::HydrometerCorrectionCalculator.new(
      measured_gravity: 1.050, sample_temp_f: 80
    ).call
    assert_in_delta 26.7, result[:sample_temp_c], 0.1
  end

  test "brix conversion is reasonable" do
    result = Alcohol::HydrometerCorrectionCalculator.new(
      measured_gravity: 1.050, sample_temp_f: 60
    ).call
    # 1.050 SG ≈ 12.4 Brix
    assert_in_delta 12.4, result[:sample_brix], 0.5
  end

  test "custom calibration temperature works" do
    result = Alcohol::HydrometerCorrectionCalculator.new(
      measured_gravity: 1.050, sample_temp_f: 68, calibration_temp_f: 68
    ).call
    assert_in_delta 1.050, result[:corrected_gravity], 0.0005
  end

  test "error when measured gravity is out of range" do
    result = Alcohol::HydrometerCorrectionCalculator.new(
      measured_gravity: 0.95, sample_temp_f: 70
    ).call
    assert_equal false, result[:valid]
  end

  test "error when sample temp out of range" do
    result = Alcohol::HydrometerCorrectionCalculator.new(
      measured_gravity: 1.050, sample_temp_f: 250
    ).call
    assert_equal false, result[:valid]
  end
end
