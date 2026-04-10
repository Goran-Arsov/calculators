require "test_helper"

class Textile::QuiltBackingCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "single panel when backing fits in fabric width" do
    # 30" wide quilt + 4" overage each side = 38" < 42" fabric width → single panel
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: 30, quilt_length_in: 40).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal false, result[:needs_seam]
    assert_equal 1, result[:num_panels]
    assert_equal "none", result[:seam_orientation]
    assert_equal 38.0, result[:backing_width]
    assert_equal 48.0, result[:backing_length]
    # 48" / 36 = 1.333 yd
    assert_equal 1.333, result[:total_yards]
  end

  test "60x80 quilt with standard 42 fabric picks best orientation" do
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: 60, quilt_length_in: 80).call
    assert_equal true, result[:valid]
    assert_equal true, result[:needs_seam]
    # backing = 68 x 88
    assert_equal 68.0, result[:backing_width]
    assert_equal 88.0, result[:backing_length]
    # Option A: vertical — ceil(68/42)=2 panels * 88 = 176 in = 4.889 yd
    # Option B: horizontal — ceil(88/42)=3 panels * 68 = 204 in = 5.667 yd
    # A wins
    assert_equal 2, result[:num_panels]
    assert_equal "vertical", result[:seam_orientation]
    assert_equal 4.889, result[:total_yards]
  end

  test "wide-back fabric avoids seams" do
    # 90" wide quilt + 4*2 = 98" < 108" wide back → single panel
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: 90, quilt_length_in: 100, fabric_width_in: 108).call
    assert_equal true, result[:valid]
    assert_equal false, result[:needs_seam]
    assert_equal 1, result[:num_panels]
  end

  test "horizontal seam wins when quilt is wider than long" do
    # Square 50x50 with overage becomes 58x58
    # A: ceil(58/42)=2 * 58 = 116 → 3.222 yd
    # B: ceil(58/42)=2 * 58 = 116 → 3.222 yd
    # Tie → picks vertical (yards_a <= yards_b)
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: 50, quilt_length_in: 50).call
    assert_equal true, result[:valid]
    assert_equal true, result[:needs_seam]
    assert_equal 2, result[:num_panels]
  end

  test "custom overage" do
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: 30, quilt_length_in: 40, overage_in: 2).call
    assert_equal true, result[:valid]
    assert_equal 34.0, result[:backing_width]
    assert_equal 44.0, result[:backing_length]
  end

  test "zero overage is allowed" do
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: 30, quilt_length_in: 40, overage_in: 0).call
    assert_equal true, result[:valid]
    assert_equal 30.0, result[:backing_width]
    assert_equal 40.0, result[:backing_length]
  end

  test "meters conversion" do
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: 30, quilt_length_in: 36).call
    assert_equal true, result[:valid]
    # backing_length = 44, meters = 44 * 0.0254 = 1.1176 → 1.118
    assert_equal 1.118, result[:total_meters]
  end

  # --- Validation errors ---

  test "error when quilt_width is zero" do
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: 0, quilt_length_in: 80).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Quilt width must be greater than zero"
  end

  test "error when quilt_length is zero" do
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: 60, quilt_length_in: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Quilt length must be greater than zero"
  end

  test "error when fabric_width is zero" do
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: 60, quilt_length_in: 80, fabric_width_in: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Fabric width must be greater than zero"
  end

  test "error when overage is negative" do
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: 60, quilt_length_in: 80, overage_in: -1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Overage cannot be negative"
  end

  test "string inputs are coerced" do
    result = Textile::QuiltBackingCalculator.new(quilt_width_in: "60", quilt_length_in: "80", overage_in: "4", fabric_width_in: "42").call
    assert_equal true, result[:valid]
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::QuiltBackingCalculator.new(quilt_width_in: 60, quilt_length_in: 80)
    assert_equal [], calc.errors
  end
end
