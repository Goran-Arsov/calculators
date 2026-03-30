require "test_helper"

class Math::AreaCalculatorTest < ActiveSupport::TestCase
  # --- Rectangle ---

  test "happy path: rectangle 5x10 = 50" do
    result = Math::AreaCalculator.new(shape: "rectangle", length: 5, width: 10).call
    assert result[:valid]
    assert_equal 50.0, result[:area]
    assert_equal "rectangle", result[:shape]
  end

  test "rectangle: square dimensions" do
    result = Math::AreaCalculator.new(shape: "rectangle", length: 7, width: 7).call
    assert result[:valid]
    assert_equal 49.0, result[:area]
  end

  test "rectangle: fractional dimensions" do
    result = Math::AreaCalculator.new(shape: "rectangle", length: 3.5, width: 2.5).call
    assert result[:valid]
    assert_equal 8.75, result[:area]
  end

  test "rectangle: very large dimensions" do
    result = Math::AreaCalculator.new(shape: "rectangle", length: 1_000_000, width: 1_000_000).call
    assert result[:valid]
    assert_equal 1_000_000_000_000.0, result[:area]
  end

  # --- Triangle ---

  test "happy path: triangle base=10 height=5 = 25" do
    result = Math::AreaCalculator.new(shape: "triangle", base: 10, height: 5).call
    assert result[:valid]
    assert_equal 25.0, result[:area]
  end

  test "triangle: fractional values" do
    result = Math::AreaCalculator.new(shape: "triangle", base: 7.5, height: 3.2).call
    assert result[:valid]
    assert_equal 12.0, result[:area]
  end

  # --- Circle ---

  test "happy path: circle radius=5" do
    result = Math::AreaCalculator.new(shape: "circle", radius: 5).call
    assert result[:valid]
    expected = ::Math::PI * 25
    assert_in_delta expected.round(4), result[:area], 0.0001
  end

  test "circle: unit radius" do
    result = Math::AreaCalculator.new(shape: "circle", radius: 1).call
    assert result[:valid]
    assert_in_delta ::Math::PI.round(4), result[:area], 0.0001
  end

  test "circle: large radius" do
    result = Math::AreaCalculator.new(shape: "circle", radius: 1000).call
    assert result[:valid]
    expected = ::Math::PI * 1_000_000
    assert_in_delta expected.round(4), result[:area], 0.1
  end

  # --- Trapezoid ---

  test "happy path: trapezoid base1=6 base2=10 height=4 = 32" do
    result = Math::AreaCalculator.new(shape: "trapezoid", base1: 6, base2: 10, height: 4).call
    assert result[:valid]
    assert_equal 32.0, result[:area]
  end

  test "trapezoid: equal bases is a rectangle" do
    result = Math::AreaCalculator.new(shape: "trapezoid", base1: 5, base2: 5, height: 10).call
    assert result[:valid]
    assert_equal 50.0, result[:area]
  end

  # --- Ellipse ---

  test "happy path: ellipse semi_major=6 semi_minor=4" do
    result = Math::AreaCalculator.new(shape: "ellipse", semi_major: 6, semi_minor: 4).call
    assert result[:valid]
    expected = ::Math::PI * 6 * 4
    assert_in_delta expected.round(4), result[:area], 0.0001
  end

  test "ellipse: equal axes is a circle" do
    result = Math::AreaCalculator.new(shape: "ellipse", semi_major: 5, semi_minor: 5).call
    assert result[:valid]
    circle = Math::AreaCalculator.new(shape: "circle", radius: 5).call
    assert_in_delta circle[:area], result[:area], 0.0001
  end

  # --- Validation: negative and zero dimensions ---

  test "zero dimension returns error" do
    result = Math::AreaCalculator.new(shape: "rectangle", length: 0, width: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Length must be positive"
  end

  test "negative dimension returns error" do
    result = Math::AreaCalculator.new(shape: "rectangle", length: -3, width: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Length must be positive"
  end

  test "multiple negative dimensions return multiple errors" do
    result = Math::AreaCalculator.new(shape: "rectangle", length: -3, width: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Length must be positive"
    assert_includes result[:errors], "Width must be positive"
  end

  test "circle: zero radius returns error" do
    result = Math::AreaCalculator.new(shape: "circle", radius: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Radius must be positive"
  end

  test "circle: negative radius returns error" do
    result = Math::AreaCalculator.new(shape: "circle", radius: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Radius must be positive"
  end

  test "triangle: zero base returns error" do
    result = Math::AreaCalculator.new(shape: "triangle", base: 0, height: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Base must be positive"
  end

  # --- Validation: invalid shape ---

  test "invalid shape returns error" do
    result = Math::AreaCalculator.new(shape: "hexagon", side: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Invalid shape"
  end

  test "empty shape string returns error" do
    result = Math::AreaCalculator.new(shape: "", radius: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Invalid shape"
  end

  # --- Result shape attribute ---

  test "result includes shape attribute" do
    result = Math::AreaCalculator.new(shape: "rectangle", length: 5, width: 10).call
    assert_equal "rectangle", result[:shape]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::AreaCalculator.new(shape: "circle", radius: 5)
    assert_equal [], calc.errors
  end
end
