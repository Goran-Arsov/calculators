require "test_helper"

class Construction::WireAmpacityCalculatorTest < ActiveSupport::TestCase
  test "12 AWG copper 75C at standard conditions" do
    result = Construction::WireAmpacityCalculator.new(
      awg: "12", material: "cu", temp_rating: 75
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 25, result[:base_ampacity]
    assert_equal 25.0, result[:adjusted_ampacity]
  end

  test "60C column has lower ampacity than 90C" do
    r60 = Construction::WireAmpacityCalculator.new(awg: "12", material: "cu", temp_rating: 60).call
    r90 = Construction::WireAmpacityCalculator.new(awg: "12", material: "cu", temp_rating: 90).call
    assert r60[:base_ampacity] < r90[:base_ampacity]
  end

  test "aluminum has lower ampacity than copper at same AWG" do
    cu = Construction::WireAmpacityCalculator.new(awg: "6", material: "cu", temp_rating: 75).call
    al = Construction::WireAmpacityCalculator.new(awg: "6", material: "al", temp_rating: 75).call
    assert al[:base_ampacity] < cu[:base_ampacity]
  end

  test "high ambient derates ampacity" do
    normal = Construction::WireAmpacityCalculator.new(awg: "10", material: "cu", temp_rating: 75, ambient_c: 30).call
    hot = Construction::WireAmpacityCalculator.new(awg: "10", material: "cu", temp_rating: 75, ambient_c: 50).call
    assert hot[:adjusted_ampacity] < normal[:adjusted_ampacity]
  end

  test "bundled conductors derate ampacity" do
    three = Construction::WireAmpacityCalculator.new(awg: "12", material: "cu", temp_rating: 75, conductor_count: 3).call
    six = Construction::WireAmpacityCalculator.new(awg: "12", material: "cu", temp_rating: 75, conductor_count: 6).call
    ten = Construction::WireAmpacityCalculator.new(awg: "12", material: "cu", temp_rating: 75, conductor_count: 10).call
    assert three[:adjusted_ampacity] > six[:adjusted_ampacity]
    assert six[:adjusted_ampacity] > ten[:adjusted_ampacity]
  end

  test "bundle derate factors match NEC" do
    six = Construction::WireAmpacityCalculator.new(awg: "12", material: "cu", temp_rating: 75, conductor_count: 6).call
    # 4-6 wires = 80% fill → 25 A × 0.8 = 20 A
    assert_in_delta 20.0, six[:adjusted_ampacity], 0.01
  end

  test "14 AWG copper 60C is 15 amps" do
    result = Construction::WireAmpacityCalculator.new(awg: "14", material: "cu", temp_rating: 60).call
    assert_equal 15, result[:base_ampacity]
  end

  test "error for unknown AWG" do
    result = Construction::WireAmpacityCalculator.new(awg: "22", material: "cu", temp_rating: 75).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "AWG not in Table 310.16"
  end

  test "error for invalid temp rating" do
    result = Construction::WireAmpacityCalculator.new(awg: "12", material: "cu", temp_rating: 100).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Temperature rating must be 60, 75, or 90 °C"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::WireAmpacityCalculator.new(awg: "12", material: "cu", temp_rating: 75)
    assert_equal [], calc.errors
  end
end
