require "test_helper"

class Textile::NeedleHookSizeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: knitting ---

  test "knitting 4.0 mm returns US 6 / UK 8" do
    result = Textile::NeedleHookSizeCalculator.new(type: "knitting", metric_mm: 4.0).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "knitting", result[:type]
    assert_equal 4.0, result[:metric_mm]
    assert_equal "6", result[:us]
    assert_equal "8", result[:uk]
    assert_equal true, result[:exact_match]
  end

  test "knitting 5.0 mm returns US 8 / UK 6" do
    result = Textile::NeedleHookSizeCalculator.new(type: "knitting", metric_mm: 5.0).call
    assert_equal "8", result[:us]
    assert_equal "6", result[:uk]
    assert_equal true, result[:exact_match]
  end

  test "knitting 3.0 mm has no US equivalent" do
    result = Textile::NeedleHookSizeCalculator.new(type: "knitting", metric_mm: 3.0).call
    assert_equal "—", result[:us]
    assert_equal "11", result[:uk]
  end

  test "knitting snaps to closest when between sizes" do
    # 4.1 is closest to 4.0
    result = Textile::NeedleHookSizeCalculator.new(type: "knitting", metric_mm: 4.1).call
    assert_equal 4.0, result[:metric_mm]
    assert_equal "6", result[:us]
    assert_equal false, result[:exact_match]
  end

  test "knitting large size 10 mm returns US 15" do
    result = Textile::NeedleHookSizeCalculator.new(type: "knitting", metric_mm: 10.0).call
    assert_equal "15", result[:us]
    assert_equal "000", result[:uk]
  end

  # --- Happy path: crochet ---

  test "crochet 5.0 mm returns H-8" do
    result = Textile::NeedleHookSizeCalculator.new(type: "crochet", metric_mm: 5.0).call
    assert_equal true, result[:valid]
    assert_equal "crochet", result[:type]
    assert_equal 5.0, result[:metric_mm]
    assert_equal "H-8", result[:us]
    assert_equal "—", result[:uk]
    assert_equal true, result[:exact_match]
  end

  test "crochet 4.0 mm returns G-6" do
    result = Textile::NeedleHookSizeCalculator.new(type: "crochet", metric_mm: 4.0).call
    assert_equal "G-6", result[:us]
  end

  test "crochet snaps to closest hook size" do
    # 5.2 is between 5.0 and 5.5, closer to 5.0
    result = Textile::NeedleHookSizeCalculator.new(type: "crochet", metric_mm: 5.2).call
    assert_equal 5.0, result[:metric_mm]
    assert_equal "H-8", result[:us]
    assert_equal false, result[:exact_match]
  end

  test "crochet 19.0 mm returns S" do
    result = Textile::NeedleHookSizeCalculator.new(type: "crochet", metric_mm: 19.0).call
    assert_equal "S", result[:us]
  end

  # --- String coercion ---

  test "string metric_mm is coerced" do
    result = Textile::NeedleHookSizeCalculator.new(type: "knitting", metric_mm: "4.0").call
    assert_equal true, result[:valid]
    assert_equal "6", result[:us]
  end

  # --- Validation errors ---

  test "error when type is invalid" do
    result = Textile::NeedleHookSizeCalculator.new(type: "sewing", metric_mm: 4.0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Type must be knitting or crochet"
  end

  test "error when metric size is zero" do
    result = Textile::NeedleHookSizeCalculator.new(type: "knitting", metric_mm: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Metric size must be greater than zero"
  end

  test "error when metric size is negative" do
    result = Textile::NeedleHookSizeCalculator.new(type: "knitting", metric_mm: -1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Metric size must be greater than zero"
  end

  test "error when metric size exceeds 30 mm" do
    result = Textile::NeedleHookSizeCalculator.new(type: "knitting", metric_mm: 35).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Metric size must be 30 mm or less"
  end

  # --- Constants exposed for view ---

  test "KNITTING_NEEDLES constant is exposed and populated" do
    assert Textile::NeedleHookSizeCalculator::KNITTING_NEEDLES.is_a?(Array)
    assert Textile::NeedleHookSizeCalculator::KNITTING_NEEDLES.any?
    first = Textile::NeedleHookSizeCalculator::KNITTING_NEEDLES.first
    assert first.key?(:metric_mm)
    assert first.key?(:us)
    assert first.key?(:uk)
  end

  test "CROCHET_HOOKS constant is exposed and populated" do
    assert Textile::NeedleHookSizeCalculator::CROCHET_HOOKS.is_a?(Array)
    assert Textile::NeedleHookSizeCalculator::CROCHET_HOOKS.any?
    first = Textile::NeedleHookSizeCalculator::CROCHET_HOOKS.first
    assert first.key?(:metric_mm)
    assert first.key?(:us)
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::NeedleHookSizeCalculator.new(type: "knitting", metric_mm: 4.0)
    assert_equal [], calc.errors
  end
end
