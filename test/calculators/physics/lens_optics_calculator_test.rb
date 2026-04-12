require "test_helper"

class Physics::LensOpticsCalculatorTest < ActiveSupport::TestCase
  test "find_image: converging lens, object beyond focal point" do
    result = Physics::LensOpticsCalculator.new(
      mode: "find_image", focal_length: 10, object_distance: 20
    ).call
    assert result[:valid]
    # 1/10 = 1/20 + 1/di => 1/di = 1/10 - 1/20 = 1/20 => di = 20
    assert_in_delta 20.0, result[:image_distance_cm], 0.01
    assert_in_delta(-1.0, result[:magnification], 0.01)
    assert result[:real_image]
  end

  test "find_image: converging lens, object at 2f gives image at 2f" do
    result = Physics::LensOpticsCalculator.new(
      mode: "find_image", focal_length: 15, object_distance: 30
    ).call
    assert result[:valid]
    assert_in_delta 30.0, result[:image_distance_cm], 0.01
    assert_in_delta(-1.0, result[:magnification], 0.01)
  end

  test "find_image: converging lens, object inside focal point gives virtual image" do
    result = Physics::LensOpticsCalculator.new(
      mode: "find_image", focal_length: 10, object_distance: 5
    ).call
    assert result[:valid]
    # 1/10 = 1/5 + 1/di => 1/di = 1/10 - 1/5 = -1/10 => di = -10
    assert_in_delta(-10.0, result[:image_distance_cm], 0.01)
    refute result[:real_image]
    assert_equal "Upright", result[:orientation]
  end

  test "find_image: diverging lens always gives virtual image" do
    result = Physics::LensOpticsCalculator.new(
      mode: "find_image", focal_length: -10, object_distance: 20
    ).call
    assert result[:valid]
    assert result[:image_distance_cm] < 0
    refute result[:real_image]
    assert_equal "Diverging (concave)", result[:lens_type]
  end

  test "find_focal: from object and image distances" do
    result = Physics::LensOpticsCalculator.new(
      mode: "find_focal", object_distance: 30, image_distance: 15
    ).call
    assert result[:valid]
    # 1/f = 1/30 + 1/15 = 3/30 = 1/10 => f = 10
    assert_in_delta 10.0, result[:focal_length_cm], 0.01
  end

  test "find_object: from focal length and image distance" do
    result = Physics::LensOpticsCalculator.new(
      mode: "find_object", focal_length: 10, image_distance: 20
    ).call
    assert result[:valid]
    # 1/10 = 1/do + 1/20 => 1/do = 1/10 - 1/20 = 1/20 => do = 20
    assert_in_delta 20.0, result[:object_distance_cm], 0.01
  end

  test "magnification enlarged image" do
    result = Physics::LensOpticsCalculator.new(
      mode: "find_image", focal_length: 10, object_distance: 15
    ).call
    assert result[:valid]
    # di = 30, m = -30/15 = -2 => enlarged
    assert_in_delta 30.0, result[:image_distance_cm], 0.01
    assert_equal "Enlarged (2.0x)", result[:size_description]
  end

  test "zero focal length returns error" do
    result = Physics::LensOpticsCalculator.new(
      mode: "find_image", focal_length: 0, object_distance: 20
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Focal length must be non-zero"
  end

  test "missing object distance returns error" do
    result = Physics::LensOpticsCalculator.new(
      mode: "find_image", focal_length: 10
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Object distance is required"
  end

  test "invalid mode returns error" do
    result = Physics::LensOpticsCalculator.new(
      mode: "invalid", focal_length: 10, object_distance: 20
    ).call
    refute result[:valid]
  end

  test "string coercion for numeric parameters" do
    result = Physics::LensOpticsCalculator.new(
      mode: "find_image", focal_length: "10", object_distance: "20"
    ).call
    assert result[:valid]
    assert_in_delta 20.0, result[:image_distance_cm], 0.01
  end
end
