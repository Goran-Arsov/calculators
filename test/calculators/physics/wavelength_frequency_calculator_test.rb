require "test_helper"

class Physics::WavelengthFrequencyCalculatorTest < ActiveSupport::TestCase
  C = Physics::WavelengthFrequencyCalculator::SPEED_OF_LIGHT
  H = Physics::WavelengthFrequencyCalculator::PLANCK_CONSTANT

  test "wavelength to frequency: 1 meter" do
    result = Physics::WavelengthFrequencyCalculator.new(wavelength: 1.0).call
    assert result[:valid]
    assert_in_delta C, result[:frequency], 10_000
    assert_in_delta 1.0, result[:wavelength], 0.001
    assert_equal :frequency, result[:solved_for]
  end

  test "frequency to wavelength: visible light ~500 THz" do
    freq = 5e14
    result = Physics::WavelengthFrequencyCalculator.new(frequency: freq).call
    assert result[:valid]
    expected_wl = C / freq
    assert_in_delta expected_wl, result[:wavelength], 1e-10
    assert_equal :wavelength, result[:solved_for]
  end

  test "energy to frequency and wavelength" do
    energy = H * 5e14
    result = Physics::WavelengthFrequencyCalculator.new(energy: energy).call
    assert result[:valid]
    assert_in_delta 5e14, result[:frequency], 1e6
    assert_equal :energy, result[:solved_for]
  end

  test "period is computed correctly" do
    result = Physics::WavelengthFrequencyCalculator.new(frequency: 100.0).call
    assert result[:valid]
    assert_in_delta 0.01, result[:period], 0.0001
  end

  test "consistency: wavelength and frequency round-trip" do
    r1 = Physics::WavelengthFrequencyCalculator.new(wavelength: 0.5).call
    r2 = Physics::WavelengthFrequencyCalculator.new(frequency: r1[:frequency]).call
    assert_in_delta 0.5, r2[:wavelength], 0.001
  end

  test "no values returns error" do
    result = Physics::WavelengthFrequencyCalculator.new.call
    refute result[:valid]
    assert_includes result[:errors], "Provide at least one value"
  end

  test "negative wavelength returns error" do
    result = Physics::WavelengthFrequencyCalculator.new(wavelength: -1).call
    refute result[:valid]
    assert_includes result[:errors], "Wavelength must be positive"
  end

  test "zero frequency returns error" do
    result = Physics::WavelengthFrequencyCalculator.new(frequency: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Frequency must be positive"
  end

  test "errors accessor" do
    calc = Physics::WavelengthFrequencyCalculator.new(wavelength: 1.0)
    assert_equal [], calc.errors
  end
end
