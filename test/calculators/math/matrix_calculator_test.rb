require "test_helper"

class Math::MatrixCalculatorTest < ActiveSupport::TestCase
  # --- Addition ---

  test "adds two 2x2 matrices" do
    result = Math::MatrixCalculator.new(matrix_a: "1,2;3,4", matrix_b: "5,6;7,8", operation: "add").call
    assert result[:valid]
    assert_equal [ [ 6.0, 8.0 ], [ 10.0, 12.0 ] ], result[:result_matrix]
  end

  test "adds two 3x3 matrices" do
    result = Math::MatrixCalculator.new(matrix_a: "1,0,0;0,1,0;0,0,1", matrix_b: "1,1,1;1,1,1;1,1,1", operation: "add").call
    assert result[:valid]
    assert_equal [ [ 2.0, 1.0, 1.0 ], [ 1.0, 2.0, 1.0 ], [ 1.0, 1.0, 2.0 ] ], result[:result_matrix]
  end

  # --- Subtraction ---

  test "subtracts two 2x2 matrices" do
    result = Math::MatrixCalculator.new(matrix_a: "5,6;7,8", matrix_b: "1,2;3,4", operation: "subtract").call
    assert result[:valid]
    assert_equal [ [ 4.0, 4.0 ], [ 4.0, 4.0 ] ], result[:result_matrix]
  end

  # --- Multiplication ---

  test "multiplies two 2x2 matrices" do
    # [[1,2],[3,4]] * [[5,6],[7,8]] = [[19,22],[43,50]]
    result = Math::MatrixCalculator.new(matrix_a: "1,2;3,4", matrix_b: "5,6;7,8", operation: "multiply").call
    assert result[:valid]
    assert_equal [ [ 19.0, 22.0 ], [ 43.0, 50.0 ] ], result[:result_matrix]
  end

  test "multiplies non-square matrices" do
    # [[1,2,3],[4,5,6]] * [[7,8],[9,10],[11,12]] = [[58,64],[139,154]]
    result = Math::MatrixCalculator.new(matrix_a: "1,2,3;4,5,6", matrix_b: "7,8;9,10;11,12", operation: "multiply").call
    assert result[:valid]
    assert_equal [ [ 58.0, 64.0 ], [ 139.0, 154.0 ] ], result[:result_matrix]
  end

  # --- Determinant ---

  test "determinant of 2x2 matrix" do
    # det([[3,8],[4,6]]) = 3*6 - 8*4 = 18 - 32 = -14
    result = Math::MatrixCalculator.new(matrix_a: "3,8;4,6", operation: "determinant_a").call
    assert result[:valid]
    assert_equal(-14.0, result[:scalar])
  end

  test "determinant of 3x3 identity matrix is 1" do
    result = Math::MatrixCalculator.new(matrix_a: "1,0,0;0,1,0;0,0,1", operation: "determinant_a").call
    assert result[:valid]
    assert_equal 1.0, result[:scalar]
  end

  test "determinant of singular matrix is 0" do
    result = Math::MatrixCalculator.new(matrix_a: "1,2;2,4", operation: "determinant_a").call
    assert result[:valid]
    assert_equal 0.0, result[:scalar]
  end

  # --- Transpose ---

  test "transpose of 2x3 matrix" do
    result = Math::MatrixCalculator.new(matrix_a: "1,2,3;4,5,6", operation: "transpose_a").call
    assert result[:valid]
    assert_equal [ [ 1.0, 4.0 ], [ 2.0, 5.0 ], [ 3.0, 6.0 ] ], result[:result_matrix]
  end

  # --- Validation ---

  test "error when adding different dimension matrices" do
    result = Math::MatrixCalculator.new(matrix_a: "1,2;3,4", matrix_b: "1,2,3;4,5,6", operation: "add").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("same dimensions") }
  end

  test "error when multiplying incompatible matrices" do
    result = Math::MatrixCalculator.new(matrix_a: "1,2;3,4", matrix_b: "1,2;3,4;5,6", operation: "multiply").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("columns") }
  end

  test "error when determinant of non-square matrix" do
    result = Math::MatrixCalculator.new(matrix_a: "1,2,3;4,5,6", operation: "determinant_a").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("square") }
  end

  test "error when matrix A is empty" do
    result = Math::MatrixCalculator.new(matrix_a: "", operation: "determinant_a").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("required") }
  end

  # --- Upper-bound validation: dimensions ---

  test "error when matrix A exceeds 10x10" do
    # 11 rows of 1 element each
    big_matrix = (1..11).map { |i| i.to_s }.join(";")
    result = Math::MatrixCalculator.new(matrix_a: big_matrix, operation: "transpose_a").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("cannot exceed 10x10") }
  end

  test "error when matrix B exceeds 10x10" do
    small = "1,2;3,4"
    big_matrix = (1..11).map { |i| i.to_s }.join(";")
    result = Math::MatrixCalculator.new(matrix_a: small, matrix_b: big_matrix, operation: "transpose_b").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("cannot exceed 10x10") }
  end

  test "10x10 matrix A is accepted" do
    rows = (1..10).map { |_| (1..10).map { |j| j.to_s }.join(",") }.join(";")
    result = Math::MatrixCalculator.new(matrix_a: rows, operation: "transpose_a").call
    assert result[:valid]
  end

  # --- Edge cases ---

  test "negative values in matrix" do
    result = Math::MatrixCalculator.new(matrix_a: "-1,-2;-3,-4", matrix_b: "1,2;3,4", operation: "add").call
    assert result[:valid]
    assert_equal [ [ 0.0, 0.0 ], [ 0.0, 0.0 ] ], result[:result_matrix]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::MatrixCalculator.new(matrix_a: "1,2;3,4", operation: "add")
    assert_equal [], calc.errors
  end
end
