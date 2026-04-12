require "test_helper"

class Relationships::HalfPlusSevenCalculatorTest < ActiveSupport::TestCase
  test "30 year old gets 22-46 range" do
    result = Relationships::HalfPlusSevenCalculator.new(age: 30).call
    assert result[:valid]
    assert_equal 22, result[:min_age]
    assert_equal 46, result[:max_age]
  end

  test "40 year old gets 27-66 range" do
    result = Relationships::HalfPlusSevenCalculator.new(age: 40).call
    assert_equal 27, result[:min_age]
    assert_equal 66, result[:max_age]
  end

  test "age under 14 errors" do
    result = Relationships::HalfPlusSevenCalculator.new(age: 12).call
    assert_equal false, result[:valid]
  end
end
