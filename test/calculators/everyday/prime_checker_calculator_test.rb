require "test_helper"

class Everyday::PrimeCheckerCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: prime numbers ---

  test "identifies 2 as prime" do
    result = Everyday::PrimeCheckerCalculator.new(number: 2).call
    assert result[:valid]
    assert result[:is_prime]
    assert_equal [ 2 ], result[:factors]
    assert_equal 1, result[:prime_index]
  end

  test "identifies 7 as prime" do
    result = Everyday::PrimeCheckerCalculator.new(number: 7).call
    assert result[:valid]
    assert result[:is_prime]
    assert_equal [ 7 ], result[:factors]
    assert_equal 4, result[:prime_index]
  end

  test "identifies 97 as prime" do
    result = Everyday::PrimeCheckerCalculator.new(number: 97).call
    assert result[:valid]
    assert result[:is_prime]
    assert_equal 25, result[:prime_index]
  end

  test "identifies 541 as prime (100th prime)" do
    result = Everyday::PrimeCheckerCalculator.new(number: 541).call
    assert result[:valid]
    assert result[:is_prime]
    assert_equal 100, result[:prime_index]
  end

  # --- Happy path: non-prime numbers ---

  test "identifies 4 as not prime with correct factors" do
    result = Everyday::PrimeCheckerCalculator.new(number: 4).call
    assert result[:valid]
    assert_not result[:is_prime]
    assert_equal [ 2, 2 ], result[:factors]
    assert_nil result[:prime_index]
  end

  test "identifies 12 as not prime with factors 2,2,3" do
    result = Everyday::PrimeCheckerCalculator.new(number: 12).call
    assert result[:valid]
    assert_not result[:is_prime]
    assert_equal [ 2, 2, 3 ], result[:factors]
  end

  test "identifies 100 as not prime with factors 2,2,5,5" do
    result = Everyday::PrimeCheckerCalculator.new(number: 100).call
    assert result[:valid]
    assert_not result[:is_prime]
    assert_equal [ 2, 2, 5, 5 ], result[:factors]
  end

  # --- Nearest primes ---

  test "nearest primes for 10" do
    result = Everyday::PrimeCheckerCalculator.new(number: 10).call
    assert result[:valid]
    assert_equal 7, result[:nearest_prime_below]
    assert_equal 11, result[:nearest_prime_above]
  end

  test "nearest prime below 2 is nil" do
    result = Everyday::PrimeCheckerCalculator.new(number: 2).call
    assert result[:valid]
    assert_nil result[:nearest_prime_below]
    assert_equal 3, result[:nearest_prime_above]
  end

  test "nearest primes for a prime number" do
    result = Everyday::PrimeCheckerCalculator.new(number: 13).call
    assert result[:valid]
    assert_equal 11, result[:nearest_prime_below]
    assert_equal 17, result[:nearest_prime_above]
  end

  # --- Large numbers ---

  test "handles large composite number" do
    result = Everyday::PrimeCheckerCalculator.new(number: 1000000).call
    assert result[:valid]
    assert_not result[:is_prime]
    product = result[:factors].reduce(:*)
    assert_equal 1000000, product
  end

  test "handles large prime" do
    result = Everyday::PrimeCheckerCalculator.new(number: 999983).call
    assert result[:valid]
    assert result[:is_prime]
  end

  # --- Validation errors ---

  test "error when number is less than 2" do
    result = Everyday::PrimeCheckerCalculator.new(number: 1).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("greater than 1") }
  end

  test "error when number is 0" do
    result = Everyday::PrimeCheckerCalculator.new(number: 0).call
    assert_equal false, result[:valid]
  end

  test "error when number is negative" do
    result = Everyday::PrimeCheckerCalculator.new(number: -7).call
    assert_equal false, result[:valid]
  end

  test "error when number exceeds maximum" do
    result = Everyday::PrimeCheckerCalculator.new(number: 20_000_000_000).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("less than") }
  end

  test "string coercion works" do
    result = Everyday::PrimeCheckerCalculator.new(number: "13").call
    assert result[:valid]
    assert result[:is_prime]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::PrimeCheckerCalculator.new(number: 7)
    assert_equal [], calc.errors
  end
end
