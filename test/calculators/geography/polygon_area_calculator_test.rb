require "test_helper"

class Geography::PolygonAreaCalculatorTest < ActiveSupport::TestCase
  test "small triangle returns positive area" do
    result = Geography::PolygonAreaCalculator.new(vertices: [
      { lat: 0, lon: 0 },
      { lat: 0, lon: 1 },
      { lat: 1, lon: 0 }
    ]).call
    assert_equal true, result[:valid]
    assert result[:area_km2] > 0
    assert_equal 3, result[:vertex_count]
  end

  test "1 degree square at equator is roughly 12,300 km2" do
    result = Geography::PolygonAreaCalculator.new(vertices: [
      { lat: 0, lon: 0 },
      { lat: 0, lon: 1 },
      { lat: 1, lon: 1 },
      { lat: 1, lon: 0 }
    ]).call
    # 1° lat × 1° lon at equator ~ 111.32 × 111.32 km ~ 12,392 km²
    assert_in_delta 12_392, result[:area_km2], 100
  end

  test "perimeter is sum of edge distances" do
    result = Geography::PolygonAreaCalculator.new(vertices: [
      { lat: 0, lon: 0 },
      { lat: 0, lon: 1 },
      { lat: 1, lon: 1 },
      { lat: 1, lon: 0 }
    ]).call
    # Perimeter ~ 2 × (111.32) + 2 × (111.32 × cos(0.5°)) ~ 445 km
    assert_in_delta 445, result[:perimeter_km], 5
  end

  test "string input vertex parsing works" do
    result = Geography::PolygonAreaCalculator.new(
      vertices: "0,0\n0,1\n1,1\n1,0"
    ).call
    assert_equal true, result[:valid]
    assert_equal 4, result[:vertex_count]
  end

  test "fewer than 3 vertices returns error" do
    result = Geography::PolygonAreaCalculator.new(vertices: [
      { lat: 0, lon: 0 },
      { lat: 1, lon: 1 }
    ]).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least 3 vertices are required to form a polygon"
  end

  test "invalid vertex coordinate returns error" do
    result = Geography::PolygonAreaCalculator.new(vertices: [
      { lat: 95, lon: 0 },
      { lat: 0, lon: 1 },
      { lat: 1, lon: 0 }
    ]).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Vertex 1: latitude must be between -90 and 90"
  end

  test "winding direction does not affect absolute area" do
    cw = Geography::PolygonAreaCalculator.new(vertices: [
      { lat: 0, lon: 0 },
      { lat: 1, lon: 0 },
      { lat: 1, lon: 1 },
      { lat: 0, lon: 1 }
    ]).call
    ccw = Geography::PolygonAreaCalculator.new(vertices: [
      { lat: 0, lon: 0 },
      { lat: 0, lon: 1 },
      { lat: 1, lon: 1 },
      { lat: 1, lon: 0 }
    ]).call
    assert_in_delta cw[:area_km2], ccw[:area_km2], 0.01
  end
end
