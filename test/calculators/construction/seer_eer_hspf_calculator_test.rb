require "test_helper"

class Construction::SeerEerHspfCalculatorTest < ActiveSupport::TestCase
  test "SEER 16 produces all other metrics" do
    result = Construction::SeerEerHspfCalculator.new(value: 16, input_type: "seer").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 16.0, result[:seer]
    assert_in_delta 15.36, result[:seer2], 0.01
    assert_in_delta 14.29, result[:eer], 0.02
    assert_in_delta 4.69, result[:cop], 0.02
  end

  test "SEER2 is about 4% lower than SEER" do
    result = Construction::SeerEerHspfCalculator.new(value: 15, input_type: "seer").call
    assert_in_delta 14.4, result[:seer2], 0.01
  end

  test "COP input converts to SEER" do
    result = Construction::SeerEerHspfCalculator.new(value: 4.0, input_type: "cop").call
    # 4.0 × 3.412 = 13.648 ≈ SEER
    assert_in_delta 13.65, result[:seer], 0.05
  end

  test "EER input round-trips reasonably to EER" do
    r = Construction::SeerEerHspfCalculator.new(value: 12, input_type: "eer").call
    # Input 12 EER → seer 13.44 → back to eer 12 exact
    assert_in_delta 12.0, r[:eer], 0.01
  end

  test "HSPF 9 converts to HSPF2" do
    result = Construction::SeerEerHspfCalculator.new(value: 9.0, input_type: "hspf").call
    # 9.0 × 0.85 = 7.65
    assert_in_delta 7.65, result[:hspf2], 0.01
  end

  test "higher input gives proportionally higher COP" do
    low = Construction::SeerEerHspfCalculator.new(value: 13, input_type: "seer").call
    high = Construction::SeerEerHspfCalculator.new(value: 20, input_type: "seer").call
    assert high[:cop] > low[:cop]
  end

  test "error when value is zero" do
    result = Construction::SeerEerHspfCalculator.new(value: 0, input_type: "seer").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Value must be greater than zero"
  end

  test "error for unknown input type" do
    result = Construction::SeerEerHspfCalculator.new(value: 16, input_type: "magic").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.start_with?("Input type must") }
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::SeerEerHspfCalculator.new(value: 16, input_type: "seer")
    assert_equal [], calc.errors
  end
end
