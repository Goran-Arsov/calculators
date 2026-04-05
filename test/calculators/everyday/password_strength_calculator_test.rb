require "test_helper"

class Everyday::PasswordStrengthCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "short lowercase password is very weak" do
    result = Everyday::PasswordStrengthCalculator.new(password: "abc").call
    assert_nil result[:errors]
    assert_equal 3, result[:length]
    assert_equal 26, result[:pool_size]
    assert_includes ["Very Weak"], result[:strength]
    assert result[:score] <= 1
  end

  test "long mixed password is very strong" do
    result = Everyday::PasswordStrengthCalculator.new(password: "C0mpl3x!Pass#2024").call
    assert_nil result[:errors]
    assert_equal 17, result[:length]
    assert_equal 95, result[:pool_size]  # 26+26+10+33
    assert_equal "Very Strong", result[:strength]
    assert result[:score] >= 6
  end

  test "entropy increases with pool size" do
    lower_only = Everyday::PasswordStrengthCalculator.new(password: "abcdefgh").call
    mixed = Everyday::PasswordStrengthCalculator.new(password: "Abcd1234").call
    assert mixed[:entropy_bits] > lower_only[:entropy_bits]
  end

  test "has_lowercase and has_uppercase detection" do
    result = Everyday::PasswordStrengthCalculator.new(password: "AbCd").call
    assert_nil result[:errors]
    assert result[:has_lowercase]
    assert result[:has_uppercase]
    assert_equal false, result[:has_digits]
    assert_equal false, result[:has_symbols]
  end

  test "digits only password" do
    result = Everyday::PasswordStrengthCalculator.new(password: "12345678").call
    assert_nil result[:errors]
    assert_equal 10, result[:pool_size]
    assert result[:has_digits]
    assert_equal false, result[:has_lowercase]
  end

  test "symbols detected" do
    result = Everyday::PasswordStrengthCalculator.new(password: "p@ss!").call
    assert_nil result[:errors]
    assert result[:has_symbols]
    assert result[:has_lowercase]
  end

  test "crack_time returns a string" do
    result = Everyday::PasswordStrengthCalculator.new(password: "test").call
    assert_nil result[:errors]
    assert_kind_of String, result[:crack_time]
  end

  test "very long password has high entropy" do
    result = Everyday::PasswordStrengthCalculator.new(password: "aB3$" * 10).call
    assert_nil result[:errors]
    assert result[:entropy_bits] > 100
  end

  # --- Validation errors ---

  test "error when password is empty" do
    result = Everyday::PasswordStrengthCalculator.new(password: "").call
    assert result[:errors].any?
    assert_includes result[:errors], "Password cannot be empty"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::PasswordStrengthCalculator.new(password: "test")
    assert_equal [], calc.errors
  end

  test "string coercion works" do
    result = Everyday::PasswordStrengthCalculator.new(password: 12345).call
    assert_nil result[:errors]
    assert_equal 5, result[:length]
    assert result[:has_digits]
  end

  test "score is capped at 7" do
    result = Everyday::PasswordStrengthCalculator.new(password: "V3ry$tr0ng!P@ssw0rd").call
    assert_nil result[:errors]
    assert result[:score] <= 7
  end
end
