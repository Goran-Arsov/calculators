require "test_helper"

class Everyday::PasswordGeneratorCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "generates a single password with default options" do
    result = Everyday::PasswordGeneratorCalculator.new(length: 16).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1, result[:passwords].size
    assert_equal 16, result[:passwords].first.length
    assert_equal 16, result[:length]
    assert_equal 1, result[:count]
    assert_equal 62, result[:pool_size] # 26+26+10
    assert result[:entropy_bits] > 0
  end

  test "generates multiple passwords" do
    result = Everyday::PasswordGeneratorCalculator.new(length: 12, count: 5).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 5, result[:passwords].size
    result[:passwords].each { |pw| assert_equal 12, pw.length }
    assert_equal 5, result[:count]
  end

  test "generates passwords with all character types" do
    result = Everyday::PasswordGeneratorCalculator.new(
      length: 20,
      include_lowercase: true,
      include_uppercase: true,
      include_digits: true,
      include_symbols: true
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:pool_size] > 62
    assert_equal 20, result[:passwords].first.length
  end

  test "generates passwords with only lowercase" do
    result = Everyday::PasswordGeneratorCalculator.new(
      length: 12,
      include_lowercase: true,
      include_uppercase: false,
      include_digits: false,
      include_symbols: false
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 26, result[:pool_size]
    assert_match(/\A[a-z]+\z/, result[:passwords].first)
  end

  test "generates passwords with only digits" do
    result = Everyday::PasswordGeneratorCalculator.new(
      length: 10,
      include_lowercase: false,
      include_uppercase: false,
      include_digits: true,
      include_symbols: false
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 10, result[:pool_size]
    assert_match(/\A\d+\z/, result[:passwords].first)
  end

  test "contains at least one character from each selected type" do
    10.times do
      result = Everyday::PasswordGeneratorCalculator.new(
        length: 12,
        include_lowercase: true,
        include_uppercase: true,
        include_digits: true,
        include_symbols: true
      ).call
      pw = result[:passwords].first
      assert_match(/[a-z]/, pw, "Missing lowercase")
      assert_match(/[A-Z]/, pw, "Missing uppercase")
      assert_match(/\d/, pw, "Missing digit")
      assert_match(/[^a-zA-Z0-9]/, pw, "Missing symbol")
    end
  end

  test "each generated password is unique" do
    result = Everyday::PasswordGeneratorCalculator.new(length: 20, count: 10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 10, result[:passwords].uniq.size
  end

  test "minimum length of 8" do
    result = Everyday::PasswordGeneratorCalculator.new(length: 8).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 8, result[:passwords].first.length
  end

  test "maximum length of 64" do
    result = Everyday::PasswordGeneratorCalculator.new(length: 64).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 64, result[:passwords].first.length
  end

  test "maximum count of 10" do
    result = Everyday::PasswordGeneratorCalculator.new(length: 12, count: 10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 10, result[:passwords].size
  end

  test "entropy increases with larger pool" do
    digits_only = Everyday::PasswordGeneratorCalculator.new(
      length: 12,
      include_lowercase: false,
      include_uppercase: false,
      include_digits: true,
      include_symbols: false
    ).call
    all_types = Everyday::PasswordGeneratorCalculator.new(
      length: 12,
      include_lowercase: true,
      include_uppercase: true,
      include_digits: true,
      include_symbols: true
    ).call
    assert all_types[:entropy_bits] > digits_only[:entropy_bits]
  end

  test "string coercion works for length and count" do
    result = Everyday::PasswordGeneratorCalculator.new(length: "16", count: "3").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 3, result[:passwords].size
    assert_equal 16, result[:passwords].first.length
  end

  # --- Validation errors ---

  test "error when no character type is selected" do
    result = Everyday::PasswordGeneratorCalculator.new(
      length: 12,
      include_lowercase: false,
      include_uppercase: false,
      include_digits: false,
      include_symbols: false
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one character type must be selected"
  end

  test "error when length is below minimum" do
    result = Everyday::PasswordGeneratorCalculator.new(length: 5).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Length must be between 8 and 64"
  end

  test "error when length is above maximum" do
    result = Everyday::PasswordGeneratorCalculator.new(length: 100).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Length must be between 8 and 64"
  end

  test "error when count is below minimum" do
    result = Everyday::PasswordGeneratorCalculator.new(length: 12, count: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Count must be between 1 and 10"
  end

  test "error when count is above maximum" do
    result = Everyday::PasswordGeneratorCalculator.new(length: 12, count: 20).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Count must be between 1 and 10"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::PasswordGeneratorCalculator.new(length: 12)
    assert_equal [], calc.errors
  end
end
