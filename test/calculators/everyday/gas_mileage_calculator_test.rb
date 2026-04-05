require "test_helper"

class Everyday::GasMileageCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "300 miles, 10 gallons → mpg=30" do
    result = Everyday::GasMileageCalculator.new(distance: 300, fuel_used: 10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 30.0, result[:mpg]
  end

  test "returns l_per_100km" do
    result = Everyday::GasMileageCalculator.new(distance: 100, fuel_used: 10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 10.0, result[:l_per_100km]
  end

  test "returns km_per_l" do
    result = Everyday::GasMileageCalculator.new(distance: 500, fuel_used: 25).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 20.0, result[:km_per_l]
  end

  test "high efficiency vehicle" do
    result = Everyday::GasMileageCalculator.new(distance: 500, fuel_used: 10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 50.0, result[:mpg]
  end

  # --- Validation errors ---

  test "error when distance is zero" do
    result = Everyday::GasMileageCalculator.new(distance: 0, fuel_used: 10).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Distance must be greater than zero"
  end

  test "error when fuel used is zero" do
    result = Everyday::GasMileageCalculator.new(distance: 300, fuel_used: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Fuel used must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::GasMileageCalculator.new(distance: 300, fuel_used: 10)
    assert_equal [], calc.errors
  end
end
