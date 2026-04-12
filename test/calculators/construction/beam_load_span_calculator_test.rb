require "test_helper"

class Construction::BeamLoadSpanCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "12ft span with 200 PLF produces valid results" do
    result = Construction::BeamLoadSpanCalculator.new(
      span_ft: 12, load_plf: 200
    ).call
    assert_equal true, result[:valid]
    assert result[:max_moment_ft_lbs] > 0
    assert result[:required_section_modulus] > 0
    assert_not_nil result[:recommended_size]
  end

  test "maximum moment calculated correctly" do
    result = Construction::BeamLoadSpanCalculator.new(
      span_ft: 12, load_plf: 200, material: "douglas_fir"
    ).call
    # w = 200/12 = 16.667 lb/in
    # M = 16.667 * (144)^2 / 8 = 16.667 * 20736 / 8 = 43,200 lb-in = 3600 ft-lbs
    assert_equal 3600, result[:max_moment_ft_lbs]
  end

  test "required section modulus calculated correctly for douglas fir" do
    result = Construction::BeamLoadSpanCalculator.new(
      span_ft: 12, load_plf: 200, material: "douglas_fir"
    ).call
    # M = 43200 lb-in, Fb = 1350 PSI
    # S = 43200 / 1350 = 32.0
    assert_equal 32.0, result[:required_section_modulus]
  end

  test "LVL material allows smaller beam" do
    result_wood = Construction::BeamLoadSpanCalculator.new(
      span_ft: 12, load_plf: 200, material: "douglas_fir"
    ).call
    result_lvl = Construction::BeamLoadSpanCalculator.new(
      span_ft: 12, load_plf: 200, material: "lvl"
    ).call
    assert result_lvl[:required_section_modulus] < result_wood[:required_section_modulus]
  end

  test "recommends correct beam size" do
    result = Construction::BeamLoadSpanCalculator.new(
      span_ft: 8, load_plf: 100, material: "douglas_fir"
    ).call
    # M = (100/12) * (96)^2 / 8 = 8.333 * 9216 / 8 = 9600 lb-in
    # S = 9600 / 1350 = 7.11 in^3
    # 2x6 has S = 7.56, which is >= 7.11
    assert_equal "2x6", result[:recommended_size]
  end

  test "returns nil recommended_size when exceeding standard sizes" do
    result = Construction::BeamLoadSpanCalculator.new(
      span_ft: 30, load_plf: 1000, material: "spruce"
    ).call
    assert_nil result[:recommended_size]
  end

  test "allowable stress matches material" do
    result = Construction::BeamLoadSpanCalculator.new(
      span_ft: 10, load_plf: 100, material: "southern_pine"
    ).call
    assert_equal 1500, result[:allowable_stress_psi]
    assert_equal "Southern Pine (No. 2)", result[:material_label]
  end

  test "all materials produce valid results" do
    %w[southern_pine douglas_fir spruce lvl steel_a36].each do |mat|
      result = Construction::BeamLoadSpanCalculator.new(
        span_ft: 10, load_plf: 100, material: mat
      ).call
      assert_equal true, result[:valid], "Material #{mat} should produce valid results"
    end
  end

  # --- Validation errors ---

  test "error when span is zero" do
    result = Construction::BeamLoadSpanCalculator.new(
      span_ft: 0, load_plf: 200
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Span must be greater than zero"
  end

  test "error when load is zero" do
    result = Construction::BeamLoadSpanCalculator.new(
      span_ft: 12, load_plf: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Load must be greater than zero"
  end

  test "error when material is invalid" do
    result = Construction::BeamLoadSpanCalculator.new(
      span_ft: 12, load_plf: 200, material: "bamboo"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Invalid material type"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::BeamLoadSpanCalculator.new(
      span_ft: 12, load_plf: 200
    )
    assert_equal [], calc.errors
  end
end
