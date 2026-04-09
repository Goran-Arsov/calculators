require "test_helper"

class Everyday::JwtGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates a valid JWT with three dot-separated parts" do
    result = Everyday::JwtGeneratorCalculator.new(
      payload_json: '{"sub":"1234567890","name":"John Doe","iat":1516239022}',
      secret_key: "my-secret"
    ).call

    assert result[:valid]
    parts = result[:jwt_token].split(".")
    assert_equal 3, parts.length
  end

  test "decoded header matches input header" do
    result = Everyday::JwtGeneratorCalculator.new(
      header_json: '{"alg":"HS256","typ":"JWT"}',
      payload_json: '{"sub":"user1"}',
      secret_key: "secret"
    ).call

    assert result[:valid]
    assert_equal "HS256", result[:decoded_header]["alg"]
    assert_equal "JWT", result[:decoded_header]["typ"]
  end

  test "decoded payload matches input payload" do
    result = Everyday::JwtGeneratorCalculator.new(
      payload_json: '{"sub":"1234567890","name":"John Doe"}',
      secret_key: "secret"
    ).call

    assert result[:valid]
    assert_equal "1234567890", result[:decoded_payload]["sub"]
    assert_equal "John Doe", result[:decoded_payload]["name"]
  end

  test "uses default header when not provided" do
    result = Everyday::JwtGeneratorCalculator.new(
      payload_json: '{"sub":"user1"}',
      secret_key: "secret"
    ).call

    assert result[:valid]
    assert_equal "HS256", result[:decoded_header]["alg"]
    assert_equal "JWT", result[:decoded_header]["typ"]
  end

  test "signature is HMAC-SHA256 of header.payload" do
    header_json = '{"alg":"HS256","typ":"JWT"}'
    payload_json = '{"sub":"user1"}'
    secret = "my-secret"

    result = Everyday::JwtGeneratorCalculator.new(
      header_json: header_json,
      payload_json: payload_json,
      secret_key: secret
    ).call

    assert result[:valid]

    header_b64 = Base64.urlsafe_encode64(header_json, padding: false)
    payload_b64 = Base64.urlsafe_encode64(payload_json, padding: false)
    signing_input = "#{header_b64}.#{payload_b64}"
    expected_sig = Base64.urlsafe_encode64(
      OpenSSL::HMAC.digest("SHA256", secret, signing_input),
      padding: false
    )

    assert_equal expected_sig, result[:signature_b64]
  end

  test "same inputs produce same JWT" do
    args = {
      header_json: '{"alg":"HS256","typ":"JWT"}',
      payload_json: '{"sub":"user1"}',
      secret_key: "secret"
    }
    result1 = Everyday::JwtGeneratorCalculator.new(**args).call
    result2 = Everyday::JwtGeneratorCalculator.new(**args).call
    assert_equal result1[:jwt_token], result2[:jwt_token]
  end

  test "different secrets produce different JWTs" do
    args = {
      header_json: '{"alg":"HS256","typ":"JWT"}',
      payload_json: '{"sub":"user1"}'
    }
    result1 = Everyday::JwtGeneratorCalculator.new(**args, secret_key: "secret1").call
    result2 = Everyday::JwtGeneratorCalculator.new(**args, secret_key: "secret2").call
    assert_not_equal result1[:jwt_token], result2[:jwt_token]
  end

  test "returns is_valid true" do
    result = Everyday::JwtGeneratorCalculator.new(
      payload_json: '{"sub":"user1"}',
      secret_key: "secret"
    ).call

    assert result[:valid]
    assert result[:is_valid]
  end

  test "returns error for empty payload" do
    result = Everyday::JwtGeneratorCalculator.new(
      payload_json: "",
      secret_key: "secret"
    ).call

    assert_not result[:valid]
    assert_includes result[:errors], "Payload JSON cannot be empty"
  end

  test "returns error for empty secret key" do
    result = Everyday::JwtGeneratorCalculator.new(
      payload_json: '{"sub":"user1"}',
      secret_key: ""
    ).call

    assert_not result[:valid]
    assert_includes result[:errors], "Secret key cannot be empty"
  end

  test "returns error for invalid header JSON" do
    result = Everyday::JwtGeneratorCalculator.new(
      header_json: "not-json",
      payload_json: '{"sub":"user1"}',
      secret_key: "secret"
    ).call

    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("header") }
  end

  test "returns error for invalid payload JSON" do
    result = Everyday::JwtGeneratorCalculator.new(
      payload_json: "{bad json}",
      secret_key: "secret"
    ).call

    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("payload") }
  end

  test "generated JWT can be decoded" do
    result = Everyday::JwtGeneratorCalculator.new(
      payload_json: '{"sub":"test","role":"admin"}',
      secret_key: "secret"
    ).call

    assert result[:valid]

    parts = result[:jwt_token].split(".")
    header = JSON.parse(Base64.urlsafe_decode64(parts[0] + "=" * ((4 - parts[0].length % 4) % 4)))
    payload = JSON.parse(Base64.urlsafe_decode64(parts[1] + "=" * ((4 - parts[1].length % 4) % 4)))

    assert_equal "HS256", header["alg"]
    assert_equal "test", payload["sub"]
    assert_equal "admin", payload["role"]
  end

  test "handles complex payload with nested objects" do
    payload = '{"user":{"id":1,"name":"Test"},"permissions":["read","write"]}'
    result = Everyday::JwtGeneratorCalculator.new(
      payload_json: payload,
      secret_key: "secret"
    ).call

    assert result[:valid]
    assert_equal 1, result[:decoded_payload]["user"]["id"]
    assert_equal [ "read", "write" ], result[:decoded_payload]["permissions"]
  end
end
