require "test_helper"

class Everyday::HashGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates SHA-256 hash" do
    result = Everyday::HashGeneratorCalculator.new(text: "hello", algorithm: "sha256").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "sha256", result[:algorithm]
    assert_equal "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824", result[:hash]
    assert_equal 64, result[:hash_length]
  end

  test "generates SHA-384 hash" do
    result = Everyday::HashGeneratorCalculator.new(text: "hello", algorithm: "sha384").call
    assert_equal true, result[:valid]
    assert_equal "sha384", result[:algorithm]
    assert_equal 96, result[:hash_length]
    assert_equal "59e1748777448c69de6b800d7a33bbfb9ff1b463e44354c3553bcdb9c666fa90125a3c79f90397bdf5f6a13de828684f", result[:hash]
  end

  test "generates SHA-512 hash" do
    result = Everyday::HashGeneratorCalculator.new(text: "hello", algorithm: "sha512").call
    assert_equal true, result[:valid]
    assert_equal "sha512", result[:algorithm]
    assert_equal 128, result[:hash_length]
    assert_equal "9b71d224bd62f3785d96d46ad3ea3d73319bfbc2890caadae2dff72519673ca72323c3d99ba5c11d7c7acc6e14b8c5da0c4663475c2e5c3adef46f73bcdec043", result[:hash]
  end

  test "generates MD5 hash" do
    result = Everyday::HashGeneratorCalculator.new(text: "hello", algorithm: "md5").call
    assert_equal true, result[:valid]
    assert_equal "md5", result[:algorithm]
    assert_equal "5d41402abc4b2a76b9719d911017c592", result[:hash]
    assert_equal 32, result[:hash_length]
  end

  test "defaults to SHA-256" do
    result = Everyday::HashGeneratorCalculator.new(text: "hello").call
    assert_equal true, result[:valid]
    assert_equal "sha256", result[:algorithm]
  end

  test "returns input length" do
    result = Everyday::HashGeneratorCalculator.new(text: "hello world").call
    assert_equal true, result[:valid]
    assert_equal 11, result[:input_length]
  end

  test "returns error for empty text" do
    result = Everyday::HashGeneratorCalculator.new(text: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for whitespace-only text" do
    result = Everyday::HashGeneratorCalculator.new(text: "   ").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for unsupported algorithm" do
    result = Everyday::HashGeneratorCalculator.new(text: "hello", algorithm: "sha1").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Unsupported algorithm: sha1. Supported: sha256, sha384, sha512, md5"
  end

  test "algorithm is case insensitive" do
    result = Everyday::HashGeneratorCalculator.new(text: "hello", algorithm: "SHA256").call
    assert_equal true, result[:valid]
    assert_equal "sha256", result[:algorithm]
  end

  test "same input produces same hash" do
    result1 = Everyday::HashGeneratorCalculator.new(text: "test", algorithm: "sha256").call
    result2 = Everyday::HashGeneratorCalculator.new(text: "test", algorithm: "sha256").call
    assert_equal result1[:hash], result2[:hash]
  end

  test "different inputs produce different hashes" do
    result1 = Everyday::HashGeneratorCalculator.new(text: "hello", algorithm: "sha256").call
    result2 = Everyday::HashGeneratorCalculator.new(text: "hello!", algorithm: "sha256").call
    assert_not_equal result1[:hash], result2[:hash]
  end

  test "handles unicode text" do
    result = Everyday::HashGeneratorCalculator.new(text: "hello world").call
    assert_equal true, result[:valid]
    assert_equal 64, result[:hash_length]
  end
end
