require "test_helper"

class Math::EigenvalueCalculatorTest < ActiveSupport::TestCase
  # --- 2x2 identity matrix ---

  test "2x2 identity matrix has eigenvalues 1, 1" do
    result = Math::EigenvalueCalculator.new(matrix: [[1, 0], [0, 1]]).call
    assert result[:valid]
    assert_equal "2x2", result[:size]
    result[:eigenvalues].each { |lam| assert_in_delta 1.0, lam, 0.01 }
  end

  # --- 2x2 diagonal matrix ---

  test "2x2 diagonal matrix has eigenvalues equal to diagonal entries" do
    result = Math::EigenvalueCalculator.new(matrix: [[3, 0], [0, 5]]).call
    assert result[:valid]
    eigenvalues = result[:eigenvalues].sort
    assert_in_delta 3.0, eigenvalues[0], 0.01
    assert_in_delta 5.0, eigenvalues[1], 0.01
  end

  # --- 2x2 general matrix ---

  test "2x2 matrix [[2,1],[1,2]] has eigenvalues 3 and 1" do
    result = Math::EigenvalueCalculator.new(matrix: [[2, 1], [1, 2]]).call
    assert result[:valid]
    eigenvalues = result[:eigenvalues].sort
    assert_in_delta 1.0, eigenvalues[0], 0.01
    assert_in_delta 3.0, eigenvalues[1], 0.01
  end

  test "trace and determinant are computed" do
    result = Math::EigenvalueCalculator.new(matrix: [[2, 1], [1, 2]]).call
    assert result[:valid]
    assert_in_delta 4.0, result[:trace], 0.01
    assert_in_delta 3.0, result[:determinant], 0.01
  end

  # --- Complex eigenvalues ---

  test "2x2 rotation matrix has complex eigenvalues" do
    result = Math::EigenvalueCalculator.new(matrix: [[0, -1], [1, 0]]).call
    assert result[:valid]
    assert result[:eigenvalues].any? { |lam| lam.is_a?(Hash) }
  end

  # --- 3x3 matrix ---

  test "3x3 identity matrix has eigenvalues 1, 1, 1" do
    result = Math::EigenvalueCalculator.new(matrix: [[1, 0, 0], [0, 1, 0], [0, 0, 1]]).call
    assert result[:valid]
    assert_equal "3x3", result[:size]
    result[:eigenvalues].each { |lam| assert_in_delta 1.0, lam, 0.01 unless lam.is_a?(Hash) }
  end

  test "3x3 diagonal matrix returns diagonal as eigenvalues" do
    result = Math::EigenvalueCalculator.new(matrix: [[2, 0, 0], [0, 3, 0], [0, 0, 7]]).call
    assert result[:valid]
    eigenvalues = result[:eigenvalues].reject { |l| l.is_a?(Hash) }.sort
    assert_in_delta 2.0, eigenvalues[0], 0.1
    assert_in_delta 3.0, eigenvalues[1], 0.1
    assert_in_delta 7.0, eigenvalues[2], 0.1
  end

  # --- String input parsing ---

  test "string input is parsed correctly" do
    result = Math::EigenvalueCalculator.new(matrix: "1 0; 0 1").call
    assert result[:valid]
    result[:eigenvalues].each { |lam| assert_in_delta 1.0, lam, 0.01 }
  end

  # --- Eigenvectors ---

  test "eigenvectors are returned" do
    result = Math::EigenvalueCalculator.new(matrix: [[2, 1], [1, 2]]).call
    assert result[:valid]
    assert result[:eigenvectors].length == 2
  end

  # --- Characteristic polynomial ---

  test "characteristic polynomial is formatted" do
    result = Math::EigenvalueCalculator.new(matrix: [[2, 1], [1, 2]]).call
    assert result[:valid]
    assert result[:characteristic_polynomial].is_a?(String)
    assert result[:characteristic_polynomial].length > 0
  end

  # --- Validation ---

  test "empty matrix returns error" do
    result = Math::EigenvalueCalculator.new(matrix: []).call
    refute result[:valid]
    assert_includes result[:errors], "Matrix cannot be empty"
  end

  test "1x1 matrix returns error" do
    result = Math::EigenvalueCalculator.new(matrix: [[5]]).call
    refute result[:valid]
    assert_includes result[:errors], "Matrix must be 2x2 or 3x3"
  end

  test "non-square matrix returns error" do
    result = Math::EigenvalueCalculator.new(matrix: [[1, 2, 3], [4, 5]]).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("elements") }
  end

  test "errors accessor returns empty array before call" do
    calc = Math::EigenvalueCalculator.new(matrix: [[1, 0], [0, 1]])
    assert_equal [], calc.errors
  end
end
