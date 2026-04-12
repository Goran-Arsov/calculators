require "test_helper"

class Math::VectorCalculatorTest < ActiveSupport::TestCase
  test "vector addition 3D" do
    result = Math::VectorCalculator.new(operation: "add", vector1: [ 1, 2, 3 ], vector2: [ 4, 5, 6 ]).call
    assert result[:valid]
    assert_equal [ 5.0, 7.0, 9.0 ], result[:result_vector]
  end

  test "vector subtraction 3D" do
    result = Math::VectorCalculator.new(operation: "subtract", vector1: [ 5, 7, 9 ], vector2: [ 1, 2, 3 ]).call
    assert result[:valid]
    assert_equal [ 4.0, 5.0, 6.0 ], result[:result_vector]
  end

  test "dot product" do
    result = Math::VectorCalculator.new(operation: "dot_product", vector1: [ 1, 2, 3 ], vector2: [ 4, 5, 6 ]).call
    assert result[:valid]
    assert_in_delta 32.0, result[:result_scalar], 1e-12
  end

  test "dot product of perpendicular vectors is zero" do
    result = Math::VectorCalculator.new(operation: "dot_product", vector1: [ 1, 0 ], vector2: [ 0, 1 ]).call
    assert result[:valid]
    assert_in_delta 0.0, result[:result_scalar], 1e-12
    assert_in_delta 90.0, result[:angle_degrees], 1e-6
  end

  test "cross product" do
    result = Math::VectorCalculator.new(operation: "cross_product", vector1: [ 1, 0, 0 ], vector2: [ 0, 1, 0 ]).call
    assert result[:valid]
    assert_in_delta 0.0, result[:result_vector][0], 1e-12
    assert_in_delta 0.0, result[:result_vector][1], 1e-12
    assert_in_delta 1.0, result[:result_vector][2], 1e-12
  end

  test "cross product requires 3D" do
    result = Math::VectorCalculator.new(operation: "cross_product", vector1: [ 1, 0 ], vector2: [ 0, 1 ]).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("3D") }
  end

  test "magnitude of (3, 4) is 5" do
    result = Math::VectorCalculator.new(operation: "magnitude", vector1: [ 3, 4 ]).call
    assert result[:valid]
    assert_in_delta 5.0, result[:magnitude], 1e-12
  end

  test "magnitude of (1, 2, 2) is 3" do
    result = Math::VectorCalculator.new(operation: "magnitude", vector1: [ 1, 2, 2 ]).call
    assert result[:valid]
    assert_in_delta 3.0, result[:magnitude], 1e-12
  end

  test "normalize unit vector" do
    result = Math::VectorCalculator.new(operation: "normalize", vector1: [ 3, 0, 0 ]).call
    assert result[:valid]
    assert_in_delta 1.0, result[:result_vector][0], 1e-12
    assert_in_delta 0.0, result[:result_vector][1], 1e-12
    assert_in_delta 0.0, result[:result_vector][2], 1e-12
  end

  test "scalar multiply" do
    result = Math::VectorCalculator.new(operation: "scalar_multiply", vector1: [ 1, 2, 3 ], scalar: 2).call
    assert result[:valid]
    assert_equal [ 2.0, 4.0, 6.0 ], result[:result_vector]
  end

  test "2D vector addition" do
    result = Math::VectorCalculator.new(operation: "add", vector1: [ 1, 2 ], vector2: [ 3, 4 ]).call
    assert result[:valid]
    assert_equal [ 4.0, 6.0 ], result[:result_vector]
    assert_equal "2D", result[:dimensions]
  end

  test "mismatched dimensions returns error" do
    result = Math::VectorCalculator.new(operation: "add", vector1: [ 1, 2 ], vector2: [ 1, 2, 3 ]).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("same number") }
  end

  test "string input parsing" do
    result = Math::VectorCalculator.new(operation: "add", vector1: "1, 2, 3", vector2: "4, 5, 6").call
    assert result[:valid]
    assert_equal [ 5.0, 7.0, 9.0 ], result[:result_vector]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::VectorCalculator.new(operation: "add", vector1: [ 1, 2 ], vector2: [ 3, 4 ])
    assert_equal [], calc.errors
  end
end
