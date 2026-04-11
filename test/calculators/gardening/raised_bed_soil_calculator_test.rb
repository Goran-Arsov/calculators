require "test_helper"

class Gardening::RaisedBedSoilCalculatorTest < ActiveSupport::TestCase
  test "4x8x12 bed holds 32 cubic feet" do
    result = Gardening::RaisedBedSoilCalculator.new(
      length_ft: 8, width_ft: 4, height_in: 12
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 32.0, result[:per_bed_cubic_feet], 0.01
    assert_in_delta 32.0, result[:total_cubic_feet], 0.01
    assert_in_delta 1.185, result[:total_cubic_yards], 0.01
  end

  test "multiple beds multiply volume" do
    result = Gardening::RaisedBedSoilCalculator.new(
      length_ft: 8, width_ft: 4, height_in: 12, beds: 4
    ).call
    assert_in_delta 128.0, result[:total_cubic_feet], 0.01
  end

  test "default mix split 60/30/10" do
    result = Gardening::RaisedBedSoilCalculator.new(
      length_ft: 10, width_ft: 10, height_in: 12
    ).call
    # 100 cubic feet total
    assert_in_delta 60.0, result[:topsoil_cubic_feet], 0.01
    assert_in_delta 30.0, result[:compost_cubic_feet], 0.01
    assert_in_delta 10.0, result[:aeration_cubic_feet], 0.01
  end

  test "mix percentages must total 100" do
    result = Gardening::RaisedBedSoilCalculator.new(
      length_ft: 8, width_ft: 4, height_in: 12,
      topsoil_pct: 50, compost_pct: 20, aeration_pct: 10
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Mix percentages must add up to 100") }
  end

  test "beds must be at least 1" do
    result = Gardening::RaisedBedSoilCalculator.new(
      length_ft: 8, width_ft: 4, height_in: 12, beds: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Number of beds must be at least 1"
  end
end
