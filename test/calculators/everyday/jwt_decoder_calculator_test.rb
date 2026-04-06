require "test_helper"

class Everyday::JwtDecoderCalculatorTest < ActiveSupport::TestCase
  # A valid JWT with header {"alg":"HS256","typ":"JWT"} and payload {"sub":"1234567890","name":"John Doe","iat":1516239022}
  VALID_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

  test "decodes a valid JWT header" do
    result = Everyday::JwtDecoderCalculator.new(token: VALID_TOKEN).call
    assert result[:valid]
    assert_equal "HS256", result[:header]["alg"]
    assert_equal "JWT", result[:header]["typ"]
  end

  test "decodes a valid JWT payload" do
    result = Everyday::JwtDecoderCalculator.new(token: VALID_TOKEN).call
    assert result[:valid]
    assert_equal "1234567890", result[:payload]["sub"]
    assert_equal "John Doe", result[:payload]["name"]
    assert_equal 1516239022, result[:payload]["iat"]
  end

  test "returns the signature segment" do
    result = Everyday::JwtDecoderCalculator.new(token: VALID_TOKEN).call
    assert result[:valid]
    assert_equal "SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c", result[:signature]
  end

  test "extracts algorithm and token type" do
    result = Everyday::JwtDecoderCalculator.new(token: VALID_TOKEN).call
    assert result[:valid]
    assert_equal "HS256", result[:algorithm]
    assert_equal "JWT", result[:token_type]
  end

  test "returns issued_at as ISO8601" do
    result = Everyday::JwtDecoderCalculator.new(token: VALID_TOKEN).call
    assert result[:valid]
    assert_equal Time.at(1516239022).utc.iso8601, result[:issued_at]
  end

  test "detects expired token" do
    # Build a token with exp in the past
    header = Base64.urlsafe_encode64('{"alg":"HS256","typ":"JWT"}', padding: false)
    payload = Base64.urlsafe_encode64("{\"sub\":\"user1\",\"exp\":#{Time.now.to_i - 3600}}", padding: false)
    token = "#{header}.#{payload}.fakesig"

    result = Everyday::JwtDecoderCalculator.new(token: token).call
    assert result[:valid]
    assert_equal true, result[:is_expired]
  end

  test "detects non-expired token" do
    header = Base64.urlsafe_encode64('{"alg":"HS256","typ":"JWT"}', padding: false)
    payload = Base64.urlsafe_encode64("{\"sub\":\"user1\",\"exp\":#{Time.now.to_i + 3600}}", padding: false)
    token = "#{header}.#{payload}.fakesig"

    result = Everyday::JwtDecoderCalculator.new(token: token).call
    assert result[:valid]
    assert_equal false, result[:is_expired]
  end

  test "returns nil for expiration fields when no exp claim" do
    result = Everyday::JwtDecoderCalculator.new(token: VALID_TOKEN).call
    assert result[:valid]
    assert_nil result[:expires_at]
    assert_nil result[:is_expired]
    assert_nil result[:expires_in_seconds]
  end

  test "returns claim count" do
    result = Everyday::JwtDecoderCalculator.new(token: VALID_TOKEN).call
    assert result[:valid]
    assert_equal 3, result[:claim_count]
  end

  test "extracts issuer and subject" do
    header = Base64.urlsafe_encode64('{"alg":"HS256","typ":"JWT"}', padding: false)
    payload = Base64.urlsafe_encode64('{"sub":"user123","iss":"auth.example.com","aud":"api.example.com"}', padding: false)
    token = "#{header}.#{payload}.fakesig"

    result = Everyday::JwtDecoderCalculator.new(token: token).call
    assert result[:valid]
    assert_equal "user123", result[:subject]
    assert_equal "auth.example.com", result[:issuer]
    assert_equal "api.example.com", result[:audience]
  end

  test "returns error for empty token" do
    result = Everyday::JwtDecoderCalculator.new(token: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Token cannot be empty"
  end

  test "returns error for token with wrong number of parts" do
    result = Everyday::JwtDecoderCalculator.new(token: "only.two").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("expected 3 parts") }
  end

  test "returns error for invalid base64 in header" do
    result = Everyday::JwtDecoderCalculator.new(token: "!!!.eyJ0ZXN0IjoxfQ.sig").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("header") }
  end

  test "returns error for invalid JSON in payload" do
    valid_header = Base64.urlsafe_encode64('{"alg":"HS256"}', padding: false)
    bad_payload = Base64.urlsafe_encode64("not json", padding: false)
    result = Everyday::JwtDecoderCalculator.new(token: "#{valid_header}.#{bad_payload}.sig").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("payload") }
  end

  test "handles token with whitespace" do
    result = Everyday::JwtDecoderCalculator.new(token: "  #{VALID_TOKEN}  ").call
    assert result[:valid]
    assert_equal "HS256", result[:header]["alg"]
  end
end
