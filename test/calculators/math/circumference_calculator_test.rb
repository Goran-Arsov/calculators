require "test_helper"

class Math::CircumferenceCalculatorTest < ActiveSupport::TestCase
  # --- Happy path with radius ---

  test "happy path: radius of 5" do
    result = Math::CircumferenceCalculator.new(radius: 5).call
    assert result[:valid]

    expected_circumference = (2 * ::Math::PI * 5).round(4)
    expected_area = (::Math::PI * 25).round(4)

    assert_equal expected_circumference, result[:circumference]
    assert_equal expected_area, result[:area]
    assert_equal 5.0, result[:radius]
    assert_equal 10.0, result[:diameter]
  end

  test "radius: unit circle" do
    result = Math::CircumferenceCalculator.new(radius: 1).call
    assert result[:valid]
    assert_in_delta(2 * ::Math::PI, result[:circumference], 0.0001)
    assert_in_delta ::Math::PI, result[:area], 0.0001
    assert_equal 1.0, result[:radius]
    assert_equal 2.0, result[:diameter]
  end

  test "radius: fractional value" do
    result = Math::CircumferenceCalculator.new(radius: 2.5).call
    assert result[:valid]
    expected_circ = (2 * ::Math::PI * 2.5).round(4)
    assert_equal expected_circ, result[:circumference]
  end

  test "radius: very large value" do
    result = Math::CircumferenceCalculator.new(radius: 1_000_000).call
    assert result[:valid]
    expected = (2 * ::Math::PI * 1_000_000).round(4)
    assert_equal expected, result[:circumference]
  end

  # --- Happy path with diameter ---

  test "happy path: diameter of 10" do
    result = Math::CircumferenceCalculator.new(diameter: 10).call
    assert result[:valid]

    expected_circumference = (2 * ::Math::PI * 5).round(4)
    expected_area = (::Math::PI * 25).round(4)

    assert_equal expected_circumference, result[:circumference]
    assert_equal expected_area, result[:area]
    assert_equal 5.0, result[:radius]
    assert_equal 10.0, result[:diameter]
  end

  test "diameter: odd value" do
    result = Math::CircumferenceCalculator.new(diameter: 7).call
    assert result[:valid]
    assert_in_delta 3.5, result[:radius], 0.0001
    assert_equal 7.0, result[:diameter]
  end

  test "diameter: very small value" do
    result = Math::CircumferenceCalculator.new(diameter: 0.001).call
    assert result[:valid]
    assert_in_delta(0.0005, result[:radius], 0.00001)
  end

  # --- Both radius and diameter provided (radius takes precedence) ---

  test "both radius and diameter: radius is used for calculations" do
    result = Math::CircumferenceCalculator.new(radius: 3, diameter: 100).call
    assert result[:valid]
    # radius is non-nil, so it should be used (r = @radius || @diameter/2)
    assert_equal 3.0, result[:radius]
    expected_circ = (2 * ::Math::PI * 3).round(4)
    assert_equal expected_circ, result[:circumference]
  end

  # --- Validation: neither provided ---

  test "no radius or diameter returns error" do
    result = Math::CircumferenceCalculator.new.call
    refute result[:valid]
    assert_includes result[:errors], "Provide either radius or diameter"
  end

  # --- Validation: zero values ---

  test "zero radius returns error" do
    result = Math::CircumferenceCalculator.new(radius: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Radius must be positive"
  end

  test "zero diameter returns error" do
    result = Math::CircumferenceCalculator.new(diameter: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Diameter must be positive"
  end

  # --- Validation: negative values ---

  test "negative radius returns error" do
    result = Math::CircumferenceCalculator.new(radius: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Radius must be positive"
  end

  test "negative diameter returns error" do
    result = Math::CircumferenceCalculator.new(diameter: -10).call
    refute result[:valid]
    assert_includes result[:errors], "Diameter must be positive"
  end

  # --- Consistency: radius and diameter results match ---

  test "radius=5 and diameter=10 produce same results" do
    r_result = Math::CircumferenceCalculator.new(radius: 5).call
    d_result = Math::CircumferenceCalculator.new(diameter: 10).call

    assert_equal r_result[:circumference], d_result[:circumference]
    assert_equal r_result[:area], d_result[:area]
    assert_equal r_result[:radius], d_result[:radius]
    assert_equal r_result[:diameter], d_result[:diameter]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::CircumferenceCalculator.new(radius: 5)
    assert_equal [], calc.errors
  end
end
