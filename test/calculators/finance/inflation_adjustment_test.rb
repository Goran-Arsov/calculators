require "test_helper"

class Finance::InflationAdjustmentTest < ActiveSupport::TestCase
  # Minimal host that mixes in the module. The module assumes the host sets
  # @annual_inflation_rate (as a decimal) during initialization.
  class Host
    include Finance::InflationAdjustment
    def initialize(rate)
      @annual_inflation_rate = rate
    end
  end

  test "apply_inflation is a no-op when inflation rate is nil" do
    result = { future_value: 10_000 }
    assert_equal result, Host.new(nil).apply_inflation(result, years: 10, nominal_keys: [ :future_value ])
  end

  test "apply_inflation is a no-op when years is zero" do
    result = { future_value: 10_000 }
    assert_equal result, Host.new(0.03).apply_inflation(result, years: 0, nominal_keys: [ :future_value ])
  end

  test "apply_inflation discounts nominal values over time and records the rate" do
    result = { future_value: 10_000 }
    adjusted = Host.new(0.03).apply_inflation(result, years: 10, nominal_keys: [ :future_value ])

    # 10000 / 1.03^10 ≈ 7440.94
    assert_in_delta 7440.94, adjusted[:real_future_value], 0.05
    assert_equal 10_000, adjusted[:future_value]
    assert_in_delta 3.0, adjusted[:annual_inflation_rate], 0.0001
  end

  test "apply_inflation skips non-numeric keys silently" do
    result = { future_value: 1_000, label: "abc" }
    adjusted = Host.new(0.02).apply_inflation(result, years: 5, nominal_keys: [ :future_value, :label ])

    assert adjusted.key?(:real_future_value)
    assert_not adjusted.key?(:real_label)
  end

  test "inflation_rate_error returns nil when rate is nil" do
    assert_nil Host.new(nil).inflation_rate_error
  end

  test "inflation_rate_error returns nil when rate is zero or positive" do
    assert_nil Host.new(0).inflation_rate_error
    assert_nil Host.new(0.05).inflation_rate_error
  end

  test "inflation_rate_error complains when rate is negative" do
    assert_equal "Inflation rate cannot be negative", Host.new(-0.01).inflation_rate_error
  end
end
