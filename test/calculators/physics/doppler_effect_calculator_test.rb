require "test_helper"

class Physics::DopplerEffectCalculatorTest < ActiveSupport::TestCase
  test "source approaching observer: frequency increases" do
    result = Physics::DopplerEffectCalculator.new(
      source_frequency: 440, source_speed: 30,
      source_moving_toward: true, observer_moving_toward: true,
      observer_speed: 0
    ).call
    assert result[:valid]
    # f' = 440 * (343 + 0) / (343 - 30) = 440 * 343 / 313 = 482.17
    expected = 440.0 * 343.0 / 313.0
    assert_in_delta expected, result[:observed_frequency_hz], 0.1
    assert result[:observed_frequency_hz] > 440
  end

  test "source receding from observer: frequency decreases" do
    result = Physics::DopplerEffectCalculator.new(
      source_frequency: 440, source_speed: 30,
      source_moving_toward: false
    ).call
    assert result[:valid]
    # f' = 440 * 343 / (343 + 30) = 440 * 343 / 373
    expected = 440.0 * 343.0 / 373.0
    assert_in_delta expected, result[:observed_frequency_hz], 0.1
    assert result[:observed_frequency_hz] < 440
  end

  test "stationary source and observer: no shift" do
    result = Physics::DopplerEffectCalculator.new(
      source_frequency: 440, source_speed: 0, observer_speed: 0
    ).call
    assert result[:valid]
    assert_in_delta 440.0, result[:observed_frequency_hz], 0.01
    assert_equal "No shift", result[:shift_direction]
  end

  test "observer approaching stationary source" do
    result = Physics::DopplerEffectCalculator.new(
      source_frequency: 440, source_speed: 0, observer_speed: 30,
      observer_moving_toward: true
    ).call
    assert result[:valid]
    expected = 440.0 * (343.0 + 30.0) / 343.0
    assert_in_delta expected, result[:observed_frequency_hz], 0.1
  end

  test "blueshift direction when approaching" do
    result = Physics::DopplerEffectCalculator.new(
      source_frequency: 440, source_speed: 30, source_moving_toward: true
    ).call
    assert result[:valid]
    assert_equal "Blueshift (higher frequency)", result[:shift_direction]
  end

  test "redshift direction when receding" do
    result = Physics::DopplerEffectCalculator.new(
      source_frequency: 440, source_speed: 30, source_moving_toward: false
    ).call
    assert result[:valid]
    assert_equal "Redshift (lower frequency)", result[:shift_direction]
  end

  test "wavelength calculations" do
    result = Physics::DopplerEffectCalculator.new(
      source_frequency: 440, source_speed: 0, observer_speed: 0
    ).call
    assert result[:valid]
    assert_in_delta(343.0 / 440.0, result[:source_wavelength_m], 0.001)
  end

  test "source at speed of sound with approach returns error" do
    result = Physics::DopplerEffectCalculator.new(
      source_frequency: 440, source_speed: 343,
      source_moving_toward: true
    ).call
    refute result[:valid]
  end

  test "zero source frequency returns error" do
    result = Physics::DopplerEffectCalculator.new(
      source_frequency: 0, source_speed: 30
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Source frequency must be a positive number"
  end

  test "custom speed of sound" do
    result = Physics::DopplerEffectCalculator.new(
      source_frequency: 440, source_speed: 0, observer_speed: 0,
      speed_of_sound: 1500
    ).call
    assert result[:valid]
    assert_in_delta 1500.0, result[:speed_of_sound_m_s], 0.1
  end

  test "string coercion" do
    result = Physics::DopplerEffectCalculator.new(
      source_frequency: "440", source_speed: "30",
      source_moving_toward: "true"
    ).call
    assert result[:valid]
  end
end
