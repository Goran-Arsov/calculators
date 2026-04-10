require "test_helper"

class Alcohol::AbvCalculatorTest < ActiveSupport::TestCase
  test "typical 1.060 to 1.012 batch" do
    result = Alcohol::AbvCalculator.new(original_gravity: 1.060, final_gravity: 1.012).call
    assert_equal true, result[:valid]
    # (1.060 - 1.012) * 131.25 = 6.30
    assert_equal 6.30, result[:abv_simple]
    # Advanced formula slightly higher
    assert_in_delta 6.51, result[:abv_advanced], 0.05
    # Apparent attenuation = 0.048 / 0.060 = 80%
    assert_equal 80.0, result[:attenuation]
    assert_equal 0.048, result[:gravity_drop]
  end

  test "abw is approximately 0.79336 of advanced abv" do
    result = Alcohol::AbvCalculator.new(original_gravity: 1.050, final_gravity: 1.010).call
    assert_in_delta result[:abv_advanced] * 0.79336, result[:abw], 0.02
  end

  test "calories per 12 oz returns reasonable value for typical beer" do
    result = Alcohol::AbvCalculator.new(original_gravity: 1.050, final_gravity: 1.012).call
    # Typical 5% beer is ~150-180 cal/12oz
    assert result[:calories_per_12oz].between?(140, 200)
  end

  test "high gravity advanced formula diverges from simple" do
    result = Alcohol::AbvCalculator.new(original_gravity: 1.090, final_gravity: 1.020).call
    # Advanced should be noticeably higher than simple
    assert result[:abv_advanced] > result[:abv_simple]
  end

  test "string inputs are coerced" do
    result = Alcohol::AbvCalculator.new(original_gravity: "1.050", final_gravity: "1.010").call
    assert_equal true, result[:valid]
    assert_equal 5.25, result[:abv_simple]
  end

  test "error when og below 1.000" do
    result = Alcohol::AbvCalculator.new(original_gravity: 0.999, final_gravity: 0.999).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Original gravity must be greater than 1.000"
  end

  test "error when fg greater than og" do
    result = Alcohol::AbvCalculator.new(original_gravity: 1.040, final_gravity: 1.050).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Final gravity cannot be greater than original gravity"
  end

  test "error when og too high" do
    result = Alcohol::AbvCalculator.new(original_gravity: 1.250, final_gravity: 1.020).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Original gravity is unrealistically high (max 1.200)"
  end

  test "errors accessor returns empty array before call" do
    calc = Alcohol::AbvCalculator.new(original_gravity: 1.050, final_gravity: 1.010)
    assert_equal [], calc.errors
  end
end
