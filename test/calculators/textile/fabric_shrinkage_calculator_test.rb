require "test_helper"

class Textile::FabricShrinkageCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates length and width shrinkage percentages" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 95, before_width: 100, after_width: 97
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 5.0, result[:length_shrinkage_pct]
    assert_equal 3.0, result[:width_shrinkage_pct]
    assert_equal 4.0, result[:avg_shrinkage_pct]
  end

  test "classifies minimal shrinkage under 2 percent" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 99, before_width: 100, after_width: 99.5
    ).call
    assert_equal true, result[:valid]
    assert_equal "Minimal shrinkage (likely synthetic or pre-shrunk)", result[:classification]
  end

  test "classifies low shrinkage between 2 and 5 percent" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 97, before_width: 100, after_width: 97
    ).call
    assert_equal "Low shrinkage (typical for treated cottons)", result[:classification]
  end

  test "classifies moderate shrinkage between 5 and 10 percent" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 93, before_width: 100, after_width: 93
    ).call
    assert_equal "Moderate shrinkage (standard untreated cotton)", result[:classification]
  end

  test "classifies high shrinkage between 10 and 15 percent" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 88, before_width: 100, after_width: 88
    ).call
    assert_equal "High shrinkage (linen, flannel, some wovens)", result[:classification]
  end

  test "classifies very high shrinkage at or above 15 percent" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 82, before_width: 100, after_width: 82
    ).call
    assert_equal "Very high shrinkage (some knits, unwashed linen, wool)", result[:classification]
  end

  test "handles negative shrinkage (stretching)" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 102, before_width: 100, after_width: 101
    ).call
    assert_equal true, result[:valid]
    assert_equal(-2.0, result[:length_shrinkage_pct])
    assert_equal(-1.0, result[:width_shrinkage_pct])
    assert_equal "Negative shrinkage — fabric stretched when washed", result[:classification]
  end

  test "project mode calculates cut size from target finished size" do
    # 10% length shrinkage, 5% width shrinkage
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 90,
      before_width: 100, after_width: 95,
      project_size_length: 36, project_size_width: 60
    ).call
    assert_equal true, result[:valid]
    assert_equal true, result[:project_mode]
    # cut_length = 36 / 0.9 = 40
    assert_equal 40.0, result[:cut_length]
    # cut_width = 60 / 0.95 ≈ 63.158
    assert_equal 63.158, result[:cut_width]
    assert_equal 4.0, result[:extra_length]
    assert_equal 3.158, result[:extra_width]
  end

  test "project_mode false when project sizes not given" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 95, before_width: 100, after_width: 95
    ).call
    assert_equal false, result[:project_mode]
    assert_nil result[:cut_length]
    assert_nil result[:cut_width]
  end

  test "string inputs are coerced" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: "100", after_length: "95", before_width: "100", after_width: "97"
    ).call
    assert_equal true, result[:valid]
    assert_equal 5.0, result[:length_shrinkage_pct]
  end

  test "empty string project sizes are treated as nil" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 95, before_width: 100, after_width: 95,
      project_size_length: "", project_size_width: ""
    ).call
    assert_equal true, result[:valid]
    assert_equal false, result[:project_mode]
  end

  # --- Validation errors ---

  test "error when before_length is zero" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 0, after_length: 95, before_width: 100, after_width: 95
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Before length must be greater than zero"
  end

  test "error when after_length is zero" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 0, before_width: 100, after_width: 95
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "After length must be greater than zero"
  end

  test "error when before_width is zero" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 95, before_width: 0, after_width: 95
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Before width must be greater than zero"
  end

  test "error when after_width is zero" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 95, before_width: 100, after_width: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "After width must be greater than zero"
  end

  test "error when project length is zero" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 95, before_width: 100, after_width: 95,
      project_size_length: 0, project_size_width: 60
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Project length must be greater than zero"
  end

  test "error when project width is negative" do
    result = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 95, before_width: 100, after_width: 95,
      project_size_length: 36, project_size_width: -1
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Project width must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::FabricShrinkageCalculator.new(
      before_length: 100, after_length: 95, before_width: 100, after_width: 95
    )
    assert_equal [], calc.errors
  end
end
