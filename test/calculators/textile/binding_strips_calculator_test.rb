require "test_helper"

class Textile::BindingStripsCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "60x80 quilt with defaults" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 60, quilt_length_in: 80).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # perimeter = 2*(60+80) = 280
    assert_equal 280.0, result[:perimeter]
    # total = 280 + 10 = 290
    assert_equal 290.0, result[:total_length_needed]
    # strips = ceil(290/42) = 7
    assert_equal 7, result[:strips_needed]
    # fabric_used = 7 * 2.5 = 17.5
    assert_equal 17.5, result[:fabric_used_in]
    # yards = 17.5/36 = 0.486
    assert_equal 0.486, result[:fabric_yards]
  end

  test "small baby quilt 36x48" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 36, quilt_length_in: 48).call
    assert_equal true, result[:valid]
    # perimeter = 168, total = 178
    assert_equal 168.0, result[:perimeter]
    assert_equal 178.0, result[:total_length_needed]
    # strips = ceil(178/42) = 5
    assert_equal 5, result[:strips_needed]
  end

  test "large king quilt 108x108" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 108, quilt_length_in: 108).call
    assert_equal true, result[:valid]
    # perimeter = 432, total = 442
    assert_equal 432.0, result[:perimeter]
    # strips = ceil(442/42) = 11
    assert_equal 11, result[:strips_needed]
  end

  test "custom strip width 2.25" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 60, quilt_length_in: 80, strip_width_in: 2.25).call
    assert_equal true, result[:valid]
    assert_equal 7, result[:strips_needed]
    # 7 * 2.25 = 15.75
    assert_equal 15.75, result[:fabric_used_in]
  end

  test "custom overage" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 60, quilt_length_in: 80, overage_in: 20).call
    assert_equal true, result[:valid]
    assert_equal 300.0, result[:total_length_needed]
    # ceil(300/42) = 8
    assert_equal 8, result[:strips_needed]
  end

  test "meters conversion" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 60, quilt_length_in: 80).call
    assert_equal true, result[:valid]
    # 17.5 * 0.0254 = 0.4445 → 0.445
    assert_equal 0.445, result[:fabric_meters]
  end

  test "string inputs are coerced" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: "60", quilt_length_in: "80", strip_width_in: "2.5", fabric_width_in: "42", overage_in: "10").call
    assert_equal true, result[:valid]
    assert_equal 7, result[:strips_needed]
  end

  # --- Validation errors ---

  test "error when quilt_width is zero" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 0, quilt_length_in: 80).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Quilt width must be greater than zero"
  end

  test "error when quilt_length is zero" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 60, quilt_length_in: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Quilt length must be greater than zero"
  end

  test "error when strip_width is zero" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 60, quilt_length_in: 80, strip_width_in: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Strip width must be greater than zero"
  end

  test "error when fabric_width is zero" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 60, quilt_length_in: 80, fabric_width_in: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Fabric width must be greater than zero"
  end

  test "error when overage is negative" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 60, quilt_length_in: 80, overage_in: -1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Overage cannot be negative"
  end

  test "zero overage is allowed" do
    result = Textile::BindingStripsCalculator.new(quilt_width_in: 60, quilt_length_in: 80, overage_in: 0).call
    assert_equal true, result[:valid]
    assert_equal 280.0, result[:total_length_needed]
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::BindingStripsCalculator.new(quilt_width_in: 60, quilt_length_in: 80)
    assert_equal [], calc.errors
  end
end
