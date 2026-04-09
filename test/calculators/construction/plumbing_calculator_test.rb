require "test_helper"

class Construction::PlumbingCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "typical house fixtures produce valid results" do
    result = Construction::PlumbingCalculator.new(
      num_toilets: 2, num_sinks: 3, num_showers: 1,
      num_bathtubs: 1, num_dishwashers: 1, num_washing_machines: 1
    ).call
    assert_equal true, result[:valid]
    assert result[:total_fixture_units] > 0
    assert result[:recommended_main_pipe_size].present?
    assert result[:supply_line_size].present?
    assert result[:fixture_breakdown].present?
  end

  test "fixture units calculated correctly" do
    result = Construction::PlumbingCalculator.new(
      num_toilets: 2, num_sinks: 3, num_showers: 1,
      num_bathtubs: 1, num_dishwashers: 1, num_washing_machines: 1
    ).call
    # 2*4 + 3*1 + 1*2 + 1*2 + 1*2 + 1*2 = 8+3+2+2+2+2 = 19
    assert_equal 19, result[:total_fixture_units]
  end

  test "small system recommends 3/4 inch pipe" do
    result = Construction::PlumbingCalculator.new(
      num_toilets: 1, num_sinks: 1
    ).call
    # 4 + 1 = 5 units
    assert_equal 5, result[:total_fixture_units]
    assert_equal "3/4\"", result[:recommended_main_pipe_size]
  end

  test "medium system recommends 1 inch pipe" do
    result = Construction::PlumbingCalculator.new(
      num_toilets: 1, num_sinks: 2, num_showers: 1
    ).call
    # 4 + 2 + 2 = 8 units
    assert_equal 8, result[:total_fixture_units]
    assert_equal "1\"", result[:recommended_main_pipe_size]
  end

  test "large system recommends 1-1/4 inch pipe" do
    result = Construction::PlumbingCalculator.new(
      num_toilets: 3, num_sinks: 4, num_showers: 2, num_bathtubs: 1
    ).call
    # 12 + 4 + 4 + 2 = 22 units
    assert_equal 22, result[:total_fixture_units]
    assert_equal "1-1/4\"", result[:recommended_main_pipe_size]
  end

  test "very large system recommends 2 inch pipe" do
    result = Construction::PlumbingCalculator.new(
      num_toilets: 10, num_sinks: 10, num_showers: 5
    ).call
    # 40 + 10 + 10 = 60 units
    assert_equal 60, result[:total_fixture_units]
    assert_equal "2\"", result[:recommended_main_pipe_size]
  end

  test "supply line is 3/4 for under 20 units" do
    result = Construction::PlumbingCalculator.new(
      num_toilets: 2, num_sinks: 3, num_showers: 1
    ).call
    # 8 + 3 + 2 = 13
    assert_equal "3/4\"", result[:supply_line_size]
  end

  test "supply line is 1 inch for 20+ units" do
    result = Construction::PlumbingCalculator.new(
      num_toilets: 3, num_sinks: 3, num_showers: 2,
      num_bathtubs: 1, num_dishwashers: 1, num_washing_machines: 1
    ).call
    # 12+3+4+2+2+2 = 25
    assert_equal "1\"", result[:supply_line_size]
  end

  test "fixture breakdown contains all fixtures" do
    result = Construction::PlumbingCalculator.new(
      num_toilets: 2, num_sinks: 3, num_showers: 1,
      num_bathtubs: 1, num_dishwashers: 1, num_washing_machines: 1
    ).call
    breakdown = result[:fixture_breakdown]
    assert_equal 2, breakdown[:toilets][:count]
    assert_equal 8, breakdown[:toilets][:total]
    assert_equal 3, breakdown[:sinks][:count]
    assert_equal 3, breakdown[:sinks][:total]
  end

  # --- Validation errors ---

  test "error when all fixtures are zero" do
    result = Construction::PlumbingCalculator.new(
      num_toilets: 0, num_sinks: 0, num_showers: 0,
      num_bathtubs: 0, num_dishwashers: 0, num_washing_machines: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one fixture is required"
  end

  test "error when toilets negative" do
    result = Construction::PlumbingCalculator.new(num_toilets: -1, num_sinks: 1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Number of toilets cannot be negative"
  end

  test "error when sinks negative" do
    result = Construction::PlumbingCalculator.new(num_toilets: 1, num_sinks: -1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Number of sinks cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::PlumbingCalculator.new(num_toilets: 1, num_sinks: 1)
    assert_equal [], calc.errors
  end
end
