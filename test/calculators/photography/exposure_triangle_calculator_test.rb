require "test_helper"

class Photography::ExposureTriangleCalculatorTest < ActiveSupport::TestCase
  # --- Solve for shutter speed ---

  test "solve for shutter when doubling ISO" do
    result = Photography::ExposureTriangleCalculator.new(
      current_iso: 100, current_aperture: 5.6, current_shutter: 1.0 / 125,
      new_iso: 200, new_aperture: 5.6
    ).call

    assert_equal true, result[:valid]
    # Doubling ISO should halve shutter speed
    assert_in_delta 1.0 / 250, result[:new_shutter], 0.001
  end

  test "solve for shutter with wider aperture" do
    result = Photography::ExposureTriangleCalculator.new(
      current_iso: 100, current_aperture: 5.6, current_shutter: 1.0 / 125,
      new_iso: 100, new_aperture: 2.8
    ).call

    assert_equal true, result[:valid]
    # Opening 2 stops should allow 4x faster shutter
    assert_in_delta 1.0 / 500, result[:new_shutter], 0.001
  end

  # --- Solve for aperture ---

  test "solve for aperture when changing ISO and shutter" do
    result = Photography::ExposureTriangleCalculator.new(
      current_iso: 100, current_aperture: 5.6, current_shutter: 1.0 / 125,
      new_iso: 100, new_shutter: 1.0 / 500
    ).call

    assert_equal true, result[:valid]
    # 2 stops faster shutter requires 2 stops wider aperture
    assert_in_delta 2.8, result[:new_aperture], 0.2
  end

  # --- Solve for ISO ---

  test "solve for ISO when changing aperture and shutter" do
    result = Photography::ExposureTriangleCalculator.new(
      current_iso: 100, current_aperture: 5.6, current_shutter: 1.0 / 125,
      new_aperture: 5.6, new_shutter: 1.0 / 250
    ).call

    assert_equal true, result[:valid]
    # Doubling shutter speed requires doubling ISO
    assert_in_delta 200, result[:new_iso], 5
  end

  test "EV is returned in result" do
    result = Photography::ExposureTriangleCalculator.new(
      current_iso: 100, current_aperture: 5.6, current_shutter: 1.0 / 125,
      new_iso: 100, new_aperture: 5.6
    ).call

    assert_equal true, result[:valid]
    assert result[:current_ev].is_a?(Numeric)
  end

  # --- Validation errors ---

  test "error when current ISO is zero" do
    result = Photography::ExposureTriangleCalculator.new(
      current_iso: 0, current_aperture: 5.6, current_shutter: 1.0 / 125,
      new_iso: 200, new_aperture: 5.6
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Current ISO must be positive"
  end

  test "error when no new values provided" do
    result = Photography::ExposureTriangleCalculator.new(
      current_iso: 100, current_aperture: 5.6, current_shutter: 1.0 / 125
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("exactly two") }
  end

  test "error when only one new value provided" do
    result = Photography::ExposureTriangleCalculator.new(
      current_iso: 100, current_aperture: 5.6, current_shutter: 1.0 / 125,
      new_iso: 200
    ).call
    assert_equal false, result[:valid]
  end

  test "errors accessor returns empty array before call" do
    calc = Photography::ExposureTriangleCalculator.new(
      current_iso: 100, current_aperture: 5.6, current_shutter: 0.008,
      new_iso: 200, new_aperture: 5.6
    )
    assert_equal [], calc.errors
  end
end
