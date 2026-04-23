require "test_helper"

class Math::LimitCalculator::ResultBuilderTest < ActiveSupport::TestCase
  RB = Math::LimitCalculator::ResultBuilder

  def base_args(overrides = {})
    {
      expression: "x^2",
      approach_value: "2",
      direction: "both",
      left_limit: nil,
      right_limit: nil
    }.merge(overrides)
  end

  test "two-sided convergent limit merges both sides" do
    result = RB.call(**base_args(left_limit: 4.0, right_limit: 4.0))
    assert result[:exists]
    assert_equal "4", result[:limit]
    assert_equal 4.0, result[:limit_numeric]
  end

  test "two-sided limit with disagreeing sides does not exist" do
    result = RB.call(**base_args(left_limit: 1.0, right_limit: 2.0))
    assert_not result[:exists]
    assert_equal "Does not exist", result[:limit]
    assert_equal "1", result[:left_limit]
    assert_equal "2", result[:right_limit]
  end

  test "two-sided limit with nil sides reports divergence" do
    result = RB.call(**base_args(left_limit: nil, right_limit: nil))
    assert_not result[:exists]
    assert_equal "Does not exist (diverges)", result[:limit]
    assert_equal "diverges", result[:left_limit]
  end

  test "one-sided left limit returns only left" do
    result = RB.call(**base_args(direction: "left", left_limit: 3.0))
    assert result[:exists]
    assert_equal "3", result[:limit]
    assert_nil result[:right_limit]
  end

  test "one-sided right limit with no value reports divergence" do
    result = RB.call(**base_args(direction: "right", right_limit: nil))
    assert_not result[:exists]
    assert_equal "Diverges", result[:limit]
  end

  test "close-enough sides collapse into a single value within tolerance" do
    result = RB.call(**base_args(left_limit: 1.0, right_limit: 1.0 + 1e-9))
    assert result[:exists]
  end

  test "integer-valued results format without decimals" do
    result = RB.call(**base_args(left_limit: 2.0, right_limit: 2.0))
    assert_equal "2", result[:limit]
  end

  test "values near zero format as 0" do
    result = RB.call(**base_args(left_limit: 1e-15, right_limit: 1e-15))
    assert_equal "0", result[:limit]
  end
end
