require "test_helper"

class Textile::YarnYardageCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "scarf medium worsted (weight 4) returns 400 yards" do
    result = Textile::YarnYardageCalculator.new(project: "scarf", size: "medium", weight_category: 4).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 400, result[:yards]
    assert_equal "scarf", result[:project]
    assert_equal "medium", result[:size]
    assert_equal 4, result[:weight_category]
    assert_equal "Worsted (4)", result[:weight_name]
  end

  test "hat small lace (weight 0) returns 300 yards" do
    result = Textile::YarnYardageCalculator.new(project: "hat", size: "small", weight_category: 0).call
    assert_equal true, result[:valid]
    assert_equal 300, result[:yards]
    assert_equal "Lace (0)", result[:weight_name]
  end

  test "super bulky large sweater returns 800 yards" do
    result = Textile::YarnYardageCalculator.new(project: "sweater", size: "large", weight_category: 7).call
    assert_equal true, result[:valid]
    assert_equal 800, result[:yards]
    assert_equal "Super Bulky (7)", result[:weight_name]
  end

  test "meters conversion is correct" do
    result = Textile::YarnYardageCalculator.new(project: "scarf", size: "medium", weight_category: 4).call
    assert_equal true, result[:valid]
    # 400 * 0.9144 = 365.76 → round 1 = 365.8
    assert_equal 365.8, result[:meters]
  end

  test "skeins_100yd rounds up" do
    # 400 yards / 100 = 4 skeins exactly
    result = Textile::YarnYardageCalculator.new(project: "scarf", size: "medium", weight_category: 4).call
    assert_equal 4, result[:skeins_100yd]
  end

  test "skeins_200yd rounds up" do
    # 250 yards / 200 = 1.25 → 2 skeins
    result = Textile::YarnYardageCalculator.new(project: "scarf", size: "small", weight_category: 4).call
    assert_equal 250, result[:yards]
    assert_equal 2, result[:skeins_200yd]
    # 250 / 100 = 3 skeins (2.5 rounds up)
    assert_equal 3, result[:skeins_100yd]
  end

  test "cardigan large dk returns 1550 yards" do
    result = Textile::YarnYardageCalculator.new(project: "cardigan", size: "large", weight_category: 3).call
    assert_equal true, result[:valid]
    assert_equal 1550, result[:yards]
  end

  test "baby blanket medium aran returns 500 yards" do
    result = Textile::YarnYardageCalculator.new(project: "baby_blanket", size: "medium", weight_category: 5).call
    assert_equal true, result[:valid]
    assert_equal 500, result[:yards]
  end

  # --- Validation errors ---

  test "error when project is unknown" do
    result = Textile::YarnYardageCalculator.new(project: "blanket", size: "medium", weight_category: 4).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert(result[:errors].any? { |e| e.include?("Project must be") })
  end

  test "error when size is invalid" do
    result = Textile::YarnYardageCalculator.new(project: "scarf", size: "xl", weight_category: 4).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Size must be small, medium, or large"
  end

  test "error when weight_category is out of range high" do
    result = Textile::YarnYardageCalculator.new(project: "scarf", size: "medium", weight_category: 8).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Weight category must be between 0 and 7"
  end

  test "error when weight_category is negative" do
    result = Textile::YarnYardageCalculator.new(project: "scarf", size: "medium", weight_category: -1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Weight category must be between 0 and 7"
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::YarnYardageCalculator.new(project: "scarf", size: "medium", weight_category: 4)
    assert_equal [], calc.errors
  end

  test "YARDAGE_TABLE and WEIGHT_NAMES constants are accessible" do
    assert_kind_of Hash, Textile::YarnYardageCalculator::YARDAGE_TABLE
    assert_equal 8, Textile::YarnYardageCalculator::WEIGHT_NAMES.length
    assert_equal "Worsted (4)", Textile::YarnYardageCalculator::WEIGHT_NAMES[4]
  end
end
