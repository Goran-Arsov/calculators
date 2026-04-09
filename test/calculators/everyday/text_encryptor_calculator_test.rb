require "test_helper"

class Everyday::TextEncryptorCalculatorTest < ActiveSupport::TestCase
  test "encrypts text and returns base64 result" do
    result = Everyday::TextEncryptorCalculator.new(
      input_text: "Hello, World!",
      password: "my-secret-password",
      mode: "encrypt"
    ).call

    assert result[:valid]
    assert result[:success]
    assert_equal "encrypt", result[:mode]
    assert_not_empty result[:result_text]
  end

  test "encrypted output is valid base64" do
    result = Everyday::TextEncryptorCalculator.new(
      input_text: "Test message",
      password: "password123",
      mode: "encrypt"
    ).call

    assert result[:valid]
    # Should not raise on decode
    decoded = Base64.strict_decode64(result[:result_text])
    assert_not_empty decoded
  end

  test "encrypt then decrypt roundtrip" do
    original = "This is a secret message with special chars: @#$%^&*()"
    password = "strong-password-123!"

    encrypted = Everyday::TextEncryptorCalculator.new(
      input_text: original,
      password: password,
      mode: "encrypt"
    ).call

    assert encrypted[:valid]

    decrypted = Everyday::TextEncryptorCalculator.new(
      input_text: encrypted[:result_text],
      password: password,
      mode: "decrypt"
    ).call

    assert decrypted[:valid]
    assert decrypted[:success]
    assert_equal original, decrypted[:result_text]
    assert_equal "decrypt", decrypted[:mode]
  end

  test "decrypt with wrong password fails" do
    encrypted = Everyday::TextEncryptorCalculator.new(
      input_text: "Secret",
      password: "correct-password",
      mode: "encrypt"
    ).call

    assert encrypted[:valid]

    decrypted = Everyday::TextEncryptorCalculator.new(
      input_text: encrypted[:result_text],
      password: "wrong-password",
      mode: "decrypt"
    ).call

    assert_not decrypted[:valid]
    assert_not decrypted[:success]
    assert decrypted[:errors].any? { |e| e.include?("Decryption failed") }
  end

  test "same plaintext encrypted twice produces different ciphertext" do
    args = { input_text: "Same message", password: "same-password", mode: "encrypt" }
    result1 = Everyday::TextEncryptorCalculator.new(**args).call
    result2 = Everyday::TextEncryptorCalculator.new(**args).call

    assert result1[:valid]
    assert result2[:valid]
    assert_not_equal result1[:result_text], result2[:result_text]
  end

  test "handles unicode text" do
    original = "Unicode test: emoji and CJK characters"
    password = "password"

    encrypted = Everyday::TextEncryptorCalculator.new(
      input_text: original,
      password: password,
      mode: "encrypt"
    ).call

    decrypted = Everyday::TextEncryptorCalculator.new(
      input_text: encrypted[:result_text],
      password: password,
      mode: "decrypt"
    ).call

    assert decrypted[:valid]
    assert_equal original, decrypted[:result_text]
  end

  test "handles empty text with error" do
    result = Everyday::TextEncryptorCalculator.new(
      input_text: "",
      password: "password",
      mode: "encrypt"
    ).call

    assert_not result[:valid]
    assert_includes result[:errors], "Input text cannot be empty"
  end

  test "handles empty password with error" do
    result = Everyday::TextEncryptorCalculator.new(
      input_text: "test",
      password: "",
      mode: "encrypt"
    ).call

    assert_not result[:valid]
    assert_includes result[:errors], "Password cannot be empty"
  end

  test "handles invalid mode with error" do
    result = Everyday::TextEncryptorCalculator.new(
      input_text: "test",
      password: "password",
      mode: "invalid"
    ).call

    assert_not result[:valid]
    assert_includes result[:errors], "Mode must be 'encrypt' or 'decrypt'"
  end

  test "handles invalid base64 input for decrypt" do
    result = Everyday::TextEncryptorCalculator.new(
      input_text: "not-valid-base64!!!",
      password: "password",
      mode: "decrypt"
    ).call

    assert_not result[:valid]
    assert_not result[:success]
  end

  test "handles long text encryption" do
    long_text = "A" * 10_000
    password = "password"

    encrypted = Everyday::TextEncryptorCalculator.new(
      input_text: long_text,
      password: password,
      mode: "encrypt"
    ).call

    decrypted = Everyday::TextEncryptorCalculator.new(
      input_text: encrypted[:result_text],
      password: password,
      mode: "decrypt"
    ).call

    assert decrypted[:valid]
    assert_equal long_text, decrypted[:result_text]
  end

  test "mode is case insensitive" do
    result = Everyday::TextEncryptorCalculator.new(
      input_text: "test",
      password: "password",
      mode: "ENCRYPT"
    ).call

    assert result[:valid]
    assert_equal "encrypt", result[:mode]
  end
end
