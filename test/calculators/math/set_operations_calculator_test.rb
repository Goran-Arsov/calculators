require "test_helper"

class Math::SetOperationsCalculatorTest < ActiveSupport::TestCase
  # --- Union ---

  test "union of {1,2,3} and {3,4,5} is {1,2,3,4,5}" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2,3", set_b: "3,4,5", operation: "union").call
    assert result[:valid]
    assert_equal %w[1 2 3 4 5], result[:result]
  end

  test "union of disjoint sets" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2", set_b: "3,4", operation: "union").call
    assert result[:valid]
    assert_equal %w[1 2 3 4], result[:result]
  end

  # --- Intersection ---

  test "intersection of {1,2,3} and {2,3,4} is {2,3}" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2,3", set_b: "2,3,4", operation: "intersection").call
    assert result[:valid]
    assert_equal %w[2 3], result[:result]
  end

  test "intersection of disjoint sets is empty" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2", set_b: "3,4", operation: "intersection").call
    assert result[:valid]
    assert_equal [], result[:result]
  end

  # --- Difference ---

  test "difference A - B: {1,2,3} - {2,3,4} = {1}" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2,3", set_b: "2,3,4", operation: "difference").call
    assert result[:valid]
    assert_equal %w[1], result[:result]
  end

  # --- Symmetric difference ---

  test "symmetric difference of {1,2,3} and {2,3,4} is {1,4}" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2,3", set_b: "2,3,4", operation: "symmetric_difference").call
    assert result[:valid]
    assert_equal %w[1 4], result[:result]
  end

  # --- Complement ---

  test "complement of {1,2} with universal {1,2,3,4,5} is {3,4,5}" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2", universal_set: "1,2,3,4,5", operation: "complement").call
    assert result[:valid]
    assert_equal %w[3 4 5], result[:result]
  end

  test "complement without universal set returns error" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2", operation: "complement").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Universal set") }
  end

  # --- Power set ---

  test "power set of {a,b} has 4 elements" do
    result = Math::SetOperationsCalculator.new(set_a: "a,b", operation: "power_set").call
    assert result[:valid]
    assert_equal 4, result[:cardinality]
  end

  test "power set of {x} has 2 elements" do
    result = Math::SetOperationsCalculator.new(set_a: "x", operation: "power_set").call
    assert result[:valid]
    assert_equal 2, result[:cardinality]
  end

  # --- Cardinality ---

  test "cardinality of {1,2,3} is 3" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2,3", operation: "cardinality").call
    assert result[:valid]
    assert_equal 3, result[:result]
  end

  # --- All operations ---

  test "all operations returns comprehensive results" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2,3", set_b: "2,3,4", operation: "all").call
    assert result[:valid]
    assert result[:results][:union].sort == %w[1 2 3 4]
    assert result[:results][:intersection].sort == %w[2 3]
    assert_equal 3, result[:results][:cardinality_a]
    assert_equal 3, result[:results][:cardinality_b]
  end

  test "all operations includes subset checks" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2", set_b: "1,2,3", operation: "all").call
    assert result[:valid]
    assert result[:results][:is_subset_a_of_b]
    refute result[:results][:is_subset_b_of_a]
  end

  # --- Array input ---

  test "accepts array input" do
    result = Math::SetOperationsCalculator.new(set_a: %w[a b c], set_b: %w[b c d], operation: "union").call
    assert result[:valid]
    assert_equal %w[a b c d], result[:result]
  end

  # --- Brace-wrapped input ---

  test "strips surrounding braces from input" do
    result = Math::SetOperationsCalculator.new(set_a: "{1,2,3}", set_b: "{2,3,4}", operation: "intersection").call
    assert result[:valid]
    assert_equal %w[2 3], result[:result]
  end

  # --- Deduplication ---

  test "duplicates in input are removed" do
    result = Math::SetOperationsCalculator.new(set_a: "1,1,2,2,3", operation: "cardinality").call
    assert result[:valid]
    assert_equal 3, result[:result]
  end

  # --- Validation ---

  test "unsupported operation returns error" do
    result = Math::SetOperationsCalculator.new(set_a: "1,2", operation: "cross_product").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported operation") }
  end

  test "errors accessor returns empty array before call" do
    calc = Math::SetOperationsCalculator.new(set_a: "1,2", set_b: "3,4", operation: "union")
    assert_equal [], calc.errors
  end
end
