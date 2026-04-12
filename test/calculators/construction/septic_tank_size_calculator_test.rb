require "test_helper"

class Construction::SepticTankSizeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "3-bedroom house produces valid results" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3
    ).call
    assert_equal true, result[:valid]
    assert_equal 3, result[:bedrooms]
    assert result[:recommended_tank_gallons] >= 1000
  end

  test "1-3 bedrooms returns 1000 gallon base" do
    [ 1, 2, 3 ].each do |beds|
      result = Construction::SepticTankSizeCalculator.new(
        bedrooms: beds
      ).call
      assert_equal 1000, result[:bedroom_based_gallons], "#{beds} bedrooms should need 1000 gallons"
    end
  end

  test "4 bedrooms adds 250 gallons" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 4
    ).call
    assert_equal 1250, result[:bedroom_based_gallons]
  end

  test "5 bedrooms adds 500 gallons" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 5
    ).call
    assert_equal 1500, result[:bedroom_based_gallons]
  end

  test "default occupants is 2 per bedroom" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3
    ).call
    assert_equal 6, result[:occupants]
  end

  test "custom occupants overrides default" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3, occupants: 4
    ).call
    assert_equal 4, result[:occupants]
  end

  test "default daily flow is 75 gal per person" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3
    ).call
    # 6 occupants x 75 = 450
    assert_equal 450, result[:daily_flow_gallons]
  end

  test "custom daily water usage overrides default" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3, daily_water_gallons: 300
    ).call
    assert_equal 300, result[:daily_flow_gallons]
  end

  test "flow-based sizing is 2x daily flow" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3
    ).call
    # 450 gpd x 2 = 900
    assert_equal 900, result[:flow_based_gallons]
  end

  test "garbage disposal adds 10%" do
    result_no = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3
    ).call
    result_yes = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3, has_garbage_disposal: true
    ).call
    assert result_yes[:required_gallons] > result_no[:required_gallons]
  end

  test "hot tub adds 10%" do
    result_no = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3
    ).call
    result_yes = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3, has_hot_tub: true
    ).call
    assert result_yes[:required_gallons] > result_no[:required_gallons]
  end

  test "recommended tank is standard size >= required" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3
    ).call
    assert result[:recommended_tank_gallons] >= result[:required_gallons]
    assert_includes [ 1000, 1250, 1500, 1750, 2000, 2500, 3000, 3500, 4000, 5000 ], result[:recommended_tank_gallons]
  end

  test "drain field estimate is positive" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3
    ).call
    assert result[:drainfield_estimate_ft] > 0
  end

  test "larger house produces larger tank recommendation" do
    result_3 = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3
    ).call
    result_6 = Construction::SepticTankSizeCalculator.new(
      bedrooms: 6
    ).call
    assert result_6[:recommended_tank_gallons] >= result_3[:recommended_tank_gallons]
  end

  # --- Validation errors ---

  test "error when bedrooms is zero" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Bedrooms must be at least 1"
  end

  test "error when bedrooms exceeds 10" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 11
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Bedrooms cannot exceed 10"
  end

  test "error when occupants is zero" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3, occupants: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Occupants must be positive"
  end

  test "error when daily water is negative" do
    result = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3, daily_water_gallons: -100
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Daily water usage must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::SepticTankSizeCalculator.new(
      bedrooms: 3
    )
    assert_equal [], calc.errors
  end
end
