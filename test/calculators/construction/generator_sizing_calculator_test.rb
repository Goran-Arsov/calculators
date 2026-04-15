require "test_helper"

class Construction::GeneratorSizingCalculatorTest < ActiveSupport::TestCase
  test "fridge plus lighting plus small loads" do
    result = Construction::GeneratorSizingCalculator.new(
      appliance_counts: { "fridge" => 1, "lighting" => 1, "small_loads" => 1 }
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # Running: 700 + 200 + 500 = 1400
    assert_equal 1400, result[:total_running_watts]
    # Peak surge = running + biggest start delta. Fridge starts at 2200 (1500 delta)
    # = 1400 + 1500 = 2900
    assert_equal 2900, result[:peak_surge_watts]
  end

  test "multiple motors only charge one start surge" do
    result = Construction::GeneratorSizingCalculator.new(
      appliance_counts: { "fridge" => 1, "freezer" => 1 }
    ).call
    # Both running 1200, biggest delta fridge (2200-700=1500), freezer (1500-500=1000)
    # Peak = 1200 + 1500 = 2700
    assert_equal 1200, result[:total_running_watts]
    assert_equal 2700, result[:peak_surge_watts]
  end

  test "headroom adds to recommendation" do
    no_headroom = Construction::GeneratorSizingCalculator.new(
      appliance_counts: { "fridge" => 1 }, headroom_pct: 0
    ).call
    with_headroom = Construction::GeneratorSizingCalculator.new(
      appliance_counts: { "fridge" => 1 }, headroom_pct: 25
    ).call
    assert with_headroom[:recommended_watts] > no_headroom[:recommended_watts]
  end

  test "kW conversion" do
    result = Construction::GeneratorSizingCalculator.new(
      appliance_counts: { "ac_3ton" => 1, "fridge" => 1, "lighting" => 1 }
    ).call
    assert_in_delta result[:recommended_watts] / 1000.0, result[:recommended_kw], 0.01
  end

  test "adding count multiplies running watts" do
    one = Construction::GeneratorSizingCalculator.new(appliance_counts: { "fridge" => 1 }).call
    two = Construction::GeneratorSizingCalculator.new(appliance_counts: { "fridge" => 2 }).call
    assert_equal 1400, two[:total_running_watts]
    assert one[:total_running_watts] == 700
  end

  test "error when no appliances selected" do
    result = Construction::GeneratorSizingCalculator.new(appliance_counts: {}).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Select at least one appliance"
  end

  test "error when zero counts only" do
    result = Construction::GeneratorSizingCalculator.new(
      appliance_counts: { "fridge" => 0, "lighting" => 0 }
    ).call
    assert_equal false, result[:valid]
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::GeneratorSizingCalculator.new(appliance_counts: { "fridge" => 1 })
    assert_equal [], calc.errors
  end
end
