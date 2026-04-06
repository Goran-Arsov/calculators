require "test_helper"

class Everyday::ChmodCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: numeric input ---

  test "converts 755 to symbolic and breakdown" do
    result = Everyday::ChmodCalculator.new(input: "755").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "755", result[:numeric]
    assert_equal "rwxr-xr-x", result[:symbolic]
    assert_equal({ read: true, write: true, execute: true }, result[:owner])
    assert_equal({ read: true, write: false, execute: true }, result[:group])
    assert_equal({ read: true, write: false, execute: true }, result[:other])
    assert_equal "Standard directory / executable", result[:common_name]
  end

  test "converts 644 to symbolic" do
    result = Everyday::ChmodCalculator.new(input: "644").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "rw-r--r--", result[:symbolic]
    assert_equal "Standard file (owner write, all read)", result[:common_name]
  end

  test "converts 777 to symbolic" do
    result = Everyday::ChmodCalculator.new(input: "777").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "rwxrwxrwx", result[:symbolic]
    assert_equal "Full access for everyone", result[:common_name]
  end

  test "converts 000 to symbolic" do
    result = Everyday::ChmodCalculator.new(input: "000").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "---------", result[:symbolic]
    assert_equal({ read: false, write: false, execute: false }, result[:owner])
    assert_equal "No permissions", result[:common_name]
  end

  test "converts 600 to symbolic" do
    result = Everyday::ChmodCalculator.new(input: "600").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "rw-------", result[:symbolic]
    assert_equal "Owner read-write only", result[:common_name]
  end

  test "uncommon permission returns nil common_name" do
    result = Everyday::ChmodCalculator.new(input: "123").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_nil result[:common_name]
    assert_equal "--x-w--wx", result[:symbolic]
  end

  # --- Happy path: symbolic input ---

  test "converts rwxr-xr-x to numeric" do
    result = Everyday::ChmodCalculator.new(input: "rwxr-xr-x").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "755", result[:numeric]
    assert_equal "rwxr-xr-x", result[:symbolic]
  end

  test "converts rw-r--r-- to numeric" do
    result = Everyday::ChmodCalculator.new(input: "rw-r--r--").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "644", result[:numeric]
  end

  test "converts rwxrwxrwx to numeric" do
    result = Everyday::ChmodCalculator.new(input: "rwxrwxrwx").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "777", result[:numeric]
  end

  test "converts --------- to numeric" do
    result = Everyday::ChmodCalculator.new(input: "---------").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "000", result[:numeric]
  end

  test "round-trips numeric to symbolic and back" do
    %w[755 644 777 000 400 500 750 664].each do |numeric|
      result1 = Everyday::ChmodCalculator.new(input: numeric).call
      result2 = Everyday::ChmodCalculator.new(input: result1[:symbolic]).call
      assert_equal numeric, result2[:numeric], "Round-trip failed for #{numeric}"
    end
  end

  test "string coercion works" do
    result = Everyday::ChmodCalculator.new(input: 755).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "755", result[:numeric]
  end

  # --- Validation errors ---

  test "error when input is empty" do
    result = Everyday::ChmodCalculator.new(input: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Input cannot be empty"
  end

  test "error for invalid numeric input" do
    result = Everyday::ChmodCalculator.new(input: "999").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Input must be a 3-digit octal number (e.g. 755) or a 9-character symbolic string (e.g. rwxr-xr-x)"
  end

  test "error for partial symbolic input" do
    result = Everyday::ChmodCalculator.new(input: "rwx").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "error for random string" do
    result = Everyday::ChmodCalculator.new(input: "hello").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "error for two-digit number" do
    result = Everyday::ChmodCalculator.new(input: "75").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "error for four-digit number" do
    result = Everyday::ChmodCalculator.new(input: "0755").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::ChmodCalculator.new(input: "755")
    assert_equal [], calc.errors
  end
end
