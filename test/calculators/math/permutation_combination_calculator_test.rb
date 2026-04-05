require "test_helper"

class Math::PermutationCombinationCalculatorTest < ActiveSupport::TestCase
  # --- Basic permutations ---

  test "P(5,3) = 60" do
    result = Math::PermutationCombinationCalculator.new(n: 5, r: 3).call
    assert result[:valid]
    assert_equal 60, result[:permutation]
  end

  test "P(10,2) = 90" do
    result = Math::PermutationCombinationCalculator.new(n: 10, r: 2).call
    assert result[:valid]
    assert_equal 90, result[:permutation]
  end

  # --- Basic combinations ---

  test "C(5,3) = 10" do
    result = Math::PermutationCombinationCalculator.new(n: 5, r: 3).call
    assert result[:valid]
    assert_equal 10, result[:combination]
  end

  test "C(10,2) = 45" do
    result = Math::PermutationCombinationCalculator.new(n: 10, r: 2).call
    assert result[:valid]
    assert_equal 45, result[:combination]
  end

  test "C(52,5) = 2598960 (poker hands)" do
    result = Math::PermutationCombinationCalculator.new(n: 52, r: 5).call
    assert result[:valid]
    assert_equal 2_598_960, result[:combination]
  end

  # --- Edge cases ---

  test "P(n,0) = 1 for any n" do
    result = Math::PermutationCombinationCalculator.new(n: 10, r: 0).call
    assert result[:valid]
    assert_equal 1, result[:permutation]
    assert_equal 1, result[:combination]
  end

  test "P(n,n) = n!" do
    result = Math::PermutationCombinationCalculator.new(n: 5, r: 5).call
    assert result[:valid]
    assert_equal 120, result[:permutation]  # 5! = 120
    assert_equal 1, result[:combination]    # C(5,5) = 1
  end

  test "P(0,0) = 1" do
    result = Math::PermutationCombinationCalculator.new(n: 0, r: 0).call
    assert result[:valid]
    assert_equal 1, result[:permutation]
    assert_equal 1, result[:combination]
  end

  test "large n value" do
    result = Math::PermutationCombinationCalculator.new(n: 20, r: 3).call
    assert result[:valid]
    # P(20,3) = 20*19*18 = 6840
    assert_equal 6840, result[:permutation]
    # C(20,3) = 6840 / 6 = 1140
    assert_equal 1140, result[:combination]
  end

  # --- Factorials returned ---

  test "returns factorial values" do
    result = Math::PermutationCombinationCalculator.new(n: 5, r: 3).call
    assert result[:valid]
    assert_equal 120, result[:n_factorial]           # 5!
    assert_equal 6, result[:r_factorial]             # 3!
    assert_equal 2, result[:n_minus_r_factorial]     # 2!
  end

  # --- Validation ---

  test "error when r > n" do
    result = Math::PermutationCombinationCalculator.new(n: 3, r: 5).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("greater than n") }
  end

  test "error when n is negative" do
    result = Math::PermutationCombinationCalculator.new(n: -1, r: 0).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("non-negative") }
  end

  test "error when r is negative" do
    result = Math::PermutationCombinationCalculator.new(n: 5, r: -1).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("non-negative") }
  end

  # --- String coercion ---

  test "string inputs are coerced to integers" do
    result = Math::PermutationCombinationCalculator.new(n: "10", r: "3").call
    assert result[:valid]
    assert_equal 720, result[:permutation]
    assert_equal 120, result[:combination]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::PermutationCombinationCalculator.new(n: 5, r: 3)
    assert_equal [], calc.errors
  end
end
