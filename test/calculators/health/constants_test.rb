require "test_helper"

class Health::ConstantsTest < ActiveSupport::TestCase
  test "ACTIVITY_MULTIPLIERS covers the five standard activity levels" do
    assert_equal %w[sedentary light moderate active very_active],
                 Health::Constants::ACTIVITY_MULTIPLIERS.keys
  end

  test "ACTIVITY_MULTIPLIERS values are monotonically increasing" do
    values = Health::Constants::ACTIVITY_MULTIPLIERS.values
    assert_equal values, values.sort,
      "Activity multipliers should increase from sedentary to very_active"
  end

  test "ACTIVITY_MULTIPLIERS values match the Harris-Benedict standard" do
    assert_equal 1.2,   Health::Constants::ACTIVITY_MULTIPLIERS["sedentary"]
    assert_equal 1.375, Health::Constants::ACTIVITY_MULTIPLIERS["light"]
    assert_equal 1.55,  Health::Constants::ACTIVITY_MULTIPLIERS["moderate"]
    assert_equal 1.725, Health::Constants::ACTIVITY_MULTIPLIERS["active"]
    assert_equal 1.9,   Health::Constants::ACTIVITY_MULTIPLIERS["very_active"]
  end

  test "ACTIVITY_LEVELS keys match ACTIVITY_MULTIPLIERS keys" do
    assert_equal Health::Constants::ACTIVITY_MULTIPLIERS.keys,
                 Health::Constants::ACTIVITY_LEVELS.keys
  end

  test "each ACTIVITY_LEVELS entry exposes a multiplier and a label" do
    Health::Constants::ACTIVITY_LEVELS.each do |key, entry|
      assert entry.key?(:multiplier), "missing :multiplier for #{key}"
      assert entry.key?(:label),      "missing :label for #{key}"
      assert_kind_of Numeric, entry[:multiplier]
      assert_kind_of String, entry[:label]
      assert_not entry[:label].empty?
    end
  end

  test "ACTIVITY_LEVELS multipliers agree with ACTIVITY_MULTIPLIERS" do
    Health::Constants::ACTIVITY_LEVELS.each do |key, entry|
      assert_equal Health::Constants::ACTIVITY_MULTIPLIERS[key], entry[:multiplier]
    end
  end

  test "constants are frozen" do
    assert Health::Constants::ACTIVITY_MULTIPLIERS.frozen?
    assert Health::Constants::ACTIVITY_LEVELS.frozen?
  end
end
