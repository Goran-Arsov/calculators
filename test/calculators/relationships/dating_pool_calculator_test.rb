require "test_helper"

class Relationships::DatingPoolCalculatorTest < ActiveSupport::TestCase
  test "default funnel produces shrinking values" do
    result = Relationships::DatingPoolCalculator.new(
      city_population: 500_000, age_min: 25, age_max: 35
    ).call
    assert result[:valid]
    assert result[:in_age_range] > result[:singles]
    assert result[:singles] > result[:compatible]
    assert result[:compatible] > result[:mutually_attracted]
  end

  test "larger city means larger pool" do
    small = Relationships::DatingPoolCalculator.new(
      city_population: 100_000, age_min: 25, age_max: 35
    ).call
    large = Relationships::DatingPoolCalculator.new(
      city_population: 1_000_000, age_min: 25, age_max: 35
    ).call
    assert large[:mutually_attracted] > small[:mutually_attracted]
  end

  test "invalid age range errors" do
    result = Relationships::DatingPoolCalculator.new(
      city_population: 100_000, age_min: 35, age_max: 25
    ).call
    assert_equal false, result[:valid]
  end
end
