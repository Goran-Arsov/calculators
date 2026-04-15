require "test_helper"

class Construction::AirChangeRateCalculatorTest < ActiveSupport::TestCase
  test "find ACH from 100 CFM and 1000 cu ft" do
    result = Construction::AirChangeRateCalculator.new(
      mode: "find_ach", cfm: 100, volume_cuft: 1000
    ).call
    assert_equal true, result[:valid]
    # ACH = 100 × 60 / 1000 = 6.0
    assert_in_delta 6.0, result[:ach], 0.01
  end

  test "find CFM from 6 ACH and 1000 cu ft" do
    result = Construction::AirChangeRateCalculator.new(
      mode: "find_cfm", target_ach: 6, volume_cuft: 1000
    ).call
    assert_equal true, result[:valid]
    # CFM = 6 × 1000 / 60 = 100
    assert_in_delta 100.0, result[:cfm], 0.01
  end

  test "find volume from 100 CFM and 6 ACH" do
    result = Construction::AirChangeRateCalculator.new(
      mode: "find_volume", cfm: 100, target_ach: 6
    ).call
    assert_equal true, result[:valid]
    # vol = 100 × 60 / 6 = 1000
    assert_in_delta 1000.0, result[:volume_cuft], 0.01
  end

  test "error when required fields missing for find_ach" do
    result = Construction::AirChangeRateCalculator.new(
      mode: "find_ach", cfm: 0, volume_cuft: 1000
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "CFM must be greater than zero"
  end

  test "error for invalid mode" do
    result = Construction::AirChangeRateCalculator.new(
      mode: "magic", cfm: 100, volume_cuft: 1000
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Mode must be find_ach, find_cfm, or find_volume"
  end

  test "recommended ACH constants defined" do
    assert Construction::AirChangeRateCalculator::RECOMMENDED_ACH["bedroom"] > 0
    assert Construction::AirChangeRateCalculator::RECOMMENDED_ACH["kitchen"] >
           Construction::AirChangeRateCalculator::RECOMMENDED_ACH["bedroom"]
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::AirChangeRateCalculator.new(mode: "find_ach", cfm: 100, volume_cuft: 1000)
    assert_equal [], calc.errors
  end
end
