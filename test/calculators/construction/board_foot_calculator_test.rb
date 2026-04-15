require "test_helper"

class Construction::BoardFootCalculatorTest < ActiveSupport::TestCase
  test "2x6x8 computes 8 BF" do
    result = Construction::BoardFootCalculator.new(thickness_in: 2, width_in: 6, length_ft: 8).call
    assert_equal true, result[:valid]
    # (2 * 6 * 8) / 12 = 8
    assert_in_delta 8.0, result[:bf_each], 0.01
    assert_in_delta 8.0, result[:total_bf], 0.01
  end

  test "quantity multiplies total BF" do
    result = Construction::BoardFootCalculator.new(thickness_in: 1, width_in: 6, length_ft: 8, quantity: 10).call
    # 1 * 6 * 8 / 12 = 4 BF each, 40 total
    assert_in_delta 40.0, result[:total_bf], 0.01
  end

  test "cubic meters conversion" do
    result = Construction::BoardFootCalculator.new(thickness_in: 2, width_in: 6, length_ft: 8).call
    # 8 BF * 0.00236 = 0.01888
    assert_in_delta 0.0189, result[:cubic_meters], 0.001
  end

  test "price computes total cost" do
    result = Construction::BoardFootCalculator.new(
      thickness_in: 1, width_in: 6, length_ft: 8, quantity: 10, price_per_bf: 5.0
    ).call
    # 40 BF * $5 = $200
    assert_in_delta 200.0, result[:total_cost], 0.01
  end

  test "total cost is nil when no price given" do
    result = Construction::BoardFootCalculator.new(thickness_in: 1, width_in: 6, length_ft: 8).call
    assert_nil result[:total_cost]
  end

  test "4/4 hardwood (1 in thick) at 8 in wide and 10 ft long" do
    result = Construction::BoardFootCalculator.new(thickness_in: 1, width_in: 8, length_ft: 10).call
    # 1 * 8 * 10 / 12 = 6.667
    assert_in_delta 6.67, result[:bf_each], 0.01
  end

  test "error when thickness is zero" do
    result = Construction::BoardFootCalculator.new(thickness_in: 0, width_in: 6, length_ft: 8).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Thickness must be greater than zero"
  end

  test "error when quantity is zero" do
    result = Construction::BoardFootCalculator.new(thickness_in: 1, width_in: 6, length_ft: 8, quantity: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Quantity must be at least 1"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::BoardFootCalculator.new(thickness_in: 1, width_in: 6, length_ft: 8)
    assert_equal [], calc.errors
  end
end
