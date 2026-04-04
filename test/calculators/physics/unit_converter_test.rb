require "test_helper"

class Physics::UnitConverterTest < ActiveSupport::TestCase
  test "meters to feet" do
    result = Physics::UnitConverter.new(conversion: "m_to_ft", value: 1).call
    assert result[:valid]
    assert_in_delta 3.28084, result[:result], 0.001
  end

  test "feet to meters" do
    result = Physics::UnitConverter.new(conversion: "ft_to_m", value: 10).call
    assert result[:valid]
    assert_in_delta 3.048, result[:result], 0.001
  end

  test "km to miles" do
    result = Physics::UnitConverter.new(conversion: "km_to_mi", value: 100).call
    assert result[:valid]
    assert_in_delta 62.137, result[:result], 0.01
  end

  test "celsius to fahrenheit" do
    result = Physics::UnitConverter.new(conversion: "c_to_f", value: 100).call
    assert result[:valid]
    assert_in_delta 212.0, result[:result], 0.01
  end

  test "fahrenheit to celsius" do
    result = Physics::UnitConverter.new(conversion: "f_to_c", value: 32).call
    assert result[:valid]
    assert_in_delta 0.0, result[:result], 0.01
  end

  test "celsius to kelvin" do
    result = Physics::UnitConverter.new(conversion: "c_to_k", value: 0).call
    assert result[:valid]
    assert_in_delta 273.15, result[:result], 0.01
  end

  test "kg to lb" do
    result = Physics::UnitConverter.new(conversion: "kg_to_lb", value: 1).call
    assert result[:valid]
    assert_in_delta 2.20462, result[:result], 0.001
  end

  test "negative temperature is valid" do
    result = Physics::UnitConverter.new(conversion: "c_to_f", value: -40).call
    assert result[:valid]
    assert_in_delta(-40.0, result[:result], 0.01)
  end

  test "unknown conversion returns error" do
    result = Physics::UnitConverter.new(conversion: "foo_to_bar", value: 1).call
    refute result[:valid]
  end

  test "errors accessor" do
    calc = Physics::UnitConverter.new(conversion: "m_to_ft", value: 1)
    assert_equal [], calc.errors
  end
end
