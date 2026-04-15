require "test_helper"

class Construction::DrywallScrewsCalculatorTest < ActiveSupport::TestCase
  test "320 sqft wall standard" do
    result = Construction::DrywallScrewsCalculator.new(
      area_sqft: 320, application: "wall_standard", waste_pct: 0
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 320 / 32 = 10 sheets × 32 screws = 320 total
    assert_equal 10, result[:sheets]
    assert_equal 320, result[:total_screws]
  end

  test "ceiling uses more screws than wall" do
    wall = Construction::DrywallScrewsCalculator.new(area_sqft: 320, application: "wall_standard").call
    ceiling = Construction::DrywallScrewsCalculator.new(area_sqft: 320, application: "ceiling").call
    assert ceiling[:total_screws] > wall[:total_screws]
  end

  test "adhesive method uses fewer screws" do
    normal = Construction::DrywallScrewsCalculator.new(area_sqft: 320, application: "wall_standard").call
    adhesive = Construction::DrywallScrewsCalculator.new(area_sqft: 320, application: "adhesive").call
    assert adhesive[:total_screws] < normal[:total_screws]
  end

  test "waste percent rounds up screws" do
    no_waste = Construction::DrywallScrewsCalculator.new(area_sqft: 320, waste_pct: 0).call
    with_waste = Construction::DrywallScrewsCalculator.new(area_sqft: 320, waste_pct: 15).call
    assert with_waste[:total_with_waste] > no_waste[:total_with_waste]
  end

  test "pounds conversion" do
    result = Construction::DrywallScrewsCalculator.new(area_sqft: 320, waste_pct: 15).call
    # 368 screws / 280 per lb = 1.31 → 2 lb
    assert_equal 2, result[:pounds_needed]
  end

  test "small area still needs at least 1 sheet" do
    result = Construction::DrywallScrewsCalculator.new(area_sqft: 10).call
    assert_equal 1, result[:sheets]
  end

  test "error when area is zero" do
    result = Construction::DrywallScrewsCalculator.new(area_sqft: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Area must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::DrywallScrewsCalculator.new(area_sqft: 320)
    assert_equal [], calc.errors
  end
end
