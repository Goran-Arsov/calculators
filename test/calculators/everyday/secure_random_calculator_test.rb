require "test_helper"

class Everyday::SecureRandomCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "generates string with default options (lowercase + uppercase + digits)" do
    result = Everyday::SecureRandomCalculator.new(length: 16).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 16, result[:generated].length
    assert_equal 16, result[:length]
    assert_equal 62, result[:pool_size]  # 26+26+10
    assert result[:entropy_bits] > 0
  end

  test "generates string with all character types" do
    result = Everyday::SecureRandomCalculator.new(
      length: 20,
      include_lowercase: true,
      include_uppercase: true,
      include_digits: true,
      include_special: true
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 20, result[:generated].length
    assert result[:pool_size] > 62
    assert result[:has_special]
  end

  test "generates string with only lowercase" do
    result = Everyday::SecureRandomCalculator.new(
      length: 12,
      include_lowercase: true,
      include_uppercase: false,
      include_digits: false,
      include_special: false
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 12, result[:generated].length
    assert_equal 26, result[:pool_size]
    assert_match(/\A[a-z]+\z/, result[:generated])
  end

  test "generates string with only uppercase" do
    result = Everyday::SecureRandomCalculator.new(
      length: 10,
      include_lowercase: false,
      include_uppercase: true,
      include_digits: false,
      include_special: false
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_match(/\A[A-Z]+\z/, result[:generated])
    assert_equal 26, result[:pool_size]
  end

  test "generates string with only digits" do
    result = Everyday::SecureRandomCalculator.new(
      length: 8,
      include_lowercase: false,
      include_uppercase: false,
      include_digits: true,
      include_special: false
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_match(/\A\d+\z/, result[:generated])
    assert_equal 10, result[:pool_size]
  end

  test "contains at least one character from each selected type" do
    10.times do
      result = Everyday::SecureRandomCalculator.new(
        length: 12,
        include_lowercase: true,
        include_uppercase: true,
        include_digits: true,
        include_special: true
      ).call
      assert_match(/[a-z]/, result[:generated], "Missing lowercase")
      assert_match(/[A-Z]/, result[:generated], "Missing uppercase")
      assert_match(/\d/, result[:generated], "Missing digit")
      assert_match(/[^a-zA-Z0-9]/, result[:generated], "Missing special")
    end
  end

  test "minimum length of 6" do
    result = Everyday::SecureRandomCalculator.new(length: 6).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 6, result[:generated].length
  end

  test "maximum length of 30" do
    result = Everyday::SecureRandomCalculator.new(length: 30).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 30, result[:generated].length
  end

  test "entropy increases with pool size" do
    digits_only = Everyday::SecureRandomCalculator.new(
      length: 12,
      include_lowercase: false,
      include_uppercase: false,
      include_digits: true,
      include_special: false
    ).call
    all_types = Everyday::SecureRandomCalculator.new(
      length: 12,
      include_lowercase: true,
      include_uppercase: true,
      include_digits: true,
      include_special: true
    ).call
    assert all_types[:entropy_bits] > digits_only[:entropy_bits]
  end

  test "each call generates a different string" do
    results = 5.times.map do
      Everyday::SecureRandomCalculator.new(length: 20).call[:generated]
    end
    assert_equal 5, results.uniq.size, "Expected unique strings but got duplicates"
  end

  # --- Validation errors ---

  test "error when no character type is selected" do
    result = Everyday::SecureRandomCalculator.new(
      length: 12,
      include_lowercase: false,
      include_uppercase: false,
      include_digits: false,
      include_special: false
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "At least one character type must be selected"
  end

  test "error when length is below minimum" do
    result = Everyday::SecureRandomCalculator.new(length: 3).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Length must be between 6 and 30"
  end

  test "error when length is above maximum" do
    result = Everyday::SecureRandomCalculator.new(length: 50).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Length must be between 6 and 30"
  end

  test "error when length is zero" do
    result = Everyday::SecureRandomCalculator.new(length: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "error when length is negative" do
    result = Everyday::SecureRandomCalculator.new(length: -5).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "string coercion works for length" do
    result = Everyday::SecureRandomCalculator.new(length: "16").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 16, result[:generated].length
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::SecureRandomCalculator.new(length: 12)
    assert_equal [], calc.errors
  end
end
