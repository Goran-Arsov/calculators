require "test_helper"

class Everyday::HmacGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates HMAC-SHA256" do
    result = Everyday::HmacGeneratorCalculator.new(message: "hello", secret_key: "secret", algorithm: "sha256").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "sha256", result[:algorithm]
    expected = OpenSSL::HMAC.hexdigest("sha256", "secret", "hello")
    assert_equal expected, result[:hmac]
    assert_equal 64, result[:hmac_length]
  end

  test "generates HMAC-SHA384" do
    result = Everyday::HmacGeneratorCalculator.new(message: "hello", secret_key: "secret", algorithm: "sha384").call
    assert_equal true, result[:valid]
    assert_equal "sha384", result[:algorithm]
    expected = OpenSSL::HMAC.hexdigest("sha384", "secret", "hello")
    assert_equal expected, result[:hmac]
    assert_equal 96, result[:hmac_length]
  end

  test "generates HMAC-SHA512" do
    result = Everyday::HmacGeneratorCalculator.new(message: "hello", secret_key: "secret", algorithm: "sha512").call
    assert_equal true, result[:valid]
    assert_equal "sha512", result[:algorithm]
    expected = OpenSSL::HMAC.hexdigest("sha512", "secret", "hello")
    assert_equal expected, result[:hmac]
    assert_equal 128, result[:hmac_length]
  end

  test "defaults to SHA-256" do
    result = Everyday::HmacGeneratorCalculator.new(message: "hello", secret_key: "secret").call
    assert_equal true, result[:valid]
    assert_equal "sha256", result[:algorithm]
  end

  test "returns message and key lengths" do
    result = Everyday::HmacGeneratorCalculator.new(message: "hello world", secret_key: "my-secret-key").call
    assert_equal true, result[:valid]
    assert_equal 11, result[:message_length]
    assert_equal 13, result[:key_length]
  end

  test "returns error for empty message" do
    result = Everyday::HmacGeneratorCalculator.new(message: "", secret_key: "secret").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Message cannot be empty"
  end

  test "returns error for whitespace-only message" do
    result = Everyday::HmacGeneratorCalculator.new(message: "   ", secret_key: "secret").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Message cannot be empty"
  end

  test "returns error for empty secret key" do
    result = Everyday::HmacGeneratorCalculator.new(message: "hello", secret_key: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Secret key cannot be empty"
  end

  test "returns error for whitespace-only secret key" do
    result = Everyday::HmacGeneratorCalculator.new(message: "hello", secret_key: "   ").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Secret key cannot be empty"
  end

  test "returns error for unsupported algorithm" do
    result = Everyday::HmacGeneratorCalculator.new(message: "hello", secret_key: "secret", algorithm: "md5").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Unsupported algorithm: md5. Supported: sha256, sha384, sha512"
  end

  test "returns multiple errors for empty message and key" do
    result = Everyday::HmacGeneratorCalculator.new(message: "", secret_key: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Message cannot be empty"
    assert_includes result[:errors], "Secret key cannot be empty"
  end

  test "algorithm is case insensitive" do
    result = Everyday::HmacGeneratorCalculator.new(message: "hello", secret_key: "secret", algorithm: "SHA256").call
    assert_equal true, result[:valid]
    assert_equal "sha256", result[:algorithm]
  end

  test "same inputs produce same HMAC" do
    result1 = Everyday::HmacGeneratorCalculator.new(message: "test", secret_key: "key").call
    result2 = Everyday::HmacGeneratorCalculator.new(message: "test", secret_key: "key").call
    assert_equal result1[:hmac], result2[:hmac]
  end

  test "different keys produce different HMACs" do
    result1 = Everyday::HmacGeneratorCalculator.new(message: "hello", secret_key: "key1").call
    result2 = Everyday::HmacGeneratorCalculator.new(message: "hello", secret_key: "key2").call
    assert_not_equal result1[:hmac], result2[:hmac]
  end

  test "different messages produce different HMACs" do
    result1 = Everyday::HmacGeneratorCalculator.new(message: "hello", secret_key: "secret").call
    result2 = Everyday::HmacGeneratorCalculator.new(message: "world", secret_key: "secret").call
    assert_not_equal result1[:hmac], result2[:hmac]
  end

  test "handles unicode message and key" do
    result = Everyday::HmacGeneratorCalculator.new(message: "hello world", secret_key: "secret key").call
    assert_equal true, result[:valid]
    assert_equal 64, result[:hmac_length]
  end
end
