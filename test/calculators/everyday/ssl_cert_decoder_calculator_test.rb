require "test_helper"

class Everyday::SslCertDecoderCalculatorTest < ActiveSupport::TestCase
  # Generate a self-signed test certificate
  def generate_test_cert(cn: "test.example.com", org: "Test Org", days_valid: 365, san_domains: [])
    key = OpenSSL::PKey::RSA.new(2048)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = rand(1..2**64)
    cert.subject = OpenSSL::X509::Name.new([
      ["CN", cn],
      ["O", org],
      ["C", "US"]
    ])
    cert.issuer = cert.subject
    cert.public_key = key.public_key
    cert.not_before = Time.now - 86_400
    cert.not_after = Time.now + (days_valid * 86_400)

    if san_domains.any?
      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = cert
      san_value = san_domains.map { |d| "DNS:#{d}" }.join(",")
      cert.add_extension(ef.create_extension("subjectAltName", san_value))
    end

    cert.sign(key, OpenSSL::Digest::SHA256.new)
    cert.to_pem
  end

  test "decodes a valid self-signed certificate" do
    pem = generate_test_cert
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert_equal "test.example.com", result[:subject][:common_name]
    assert_equal "Test Org", result[:subject][:organization]
    assert_equal "US", result[:subject][:country]
    assert result[:is_self_signed]
    assert_equal "RSA", result[:public_key_algorithm]
    assert_equal 2048, result[:public_key_size]
  end

  test "returns issuer information" do
    pem = generate_test_cert(cn: "mycert.com", org: "My Org")
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert_equal "mycert.com", result[:issuer][:common_name]
    assert_equal "My Org", result[:issuer][:organization]
  end

  test "returns serial number as hex" do
    pem = generate_test_cert
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert_match(/\A[0-9A-F]+\z/, result[:serial_number])
  end

  test "returns validity dates in ISO 8601 format" do
    pem = generate_test_cert
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert_nothing_raised { Time.iso8601(result[:not_before]) }
    assert_nothing_raised { Time.iso8601(result[:not_after]) }
  end

  test "detects valid (non-expired) certificate" do
    pem = generate_test_cert(days_valid: 365)
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert_not result[:is_expired]
    assert_equal "valid", result[:expiry_status]
    assert result[:days_until_expiry] > 30
  end

  test "detects expiring soon certificate" do
    pem = generate_test_cert(days_valid: 15)
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert_not result[:is_expired]
    assert_equal "expiring_soon", result[:expiry_status]
    assert result[:days_until_expiry] <= 30
  end

  test "detects expired certificate" do
    pem = generate_test_cert(days_valid: -5)
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert result[:is_expired]
    assert_equal "expired", result[:expiry_status]
    assert result[:days_until_expiry] < 0
  end

  test "returns signature algorithm" do
    pem = generate_test_cert
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert_includes result[:signature_algorithm].downcase, "sha256"
  end

  test "extracts subject alternative names" do
    pem = generate_test_cert(san_domains: ["example.com", "www.example.com", "api.example.com"])
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert_equal 3, result[:subject_alternative_names].size
    assert_includes result[:subject_alternative_names], "example.com"
    assert_includes result[:subject_alternative_names], "www.example.com"
    assert_includes result[:subject_alternative_names], "api.example.com"
  end

  test "returns empty SANs when none present" do
    pem = generate_test_cert(san_domains: [])
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert_empty result[:subject_alternative_names]
  end

  test "returns SHA-1 and SHA-256 fingerprints" do
    pem = generate_test_cert
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert_match(/\A([0-9A-F]{2}:){19}[0-9A-F]{2}\z/, result[:fingerprints][:sha1])
    assert_match(/\A([0-9A-F]{2}:){31}[0-9A-F]{2}\z/, result[:fingerprints][:sha256])
  end

  test "returns certificate version" do
    pem = generate_test_cert
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert result[:valid]
    assert_equal 3, result[:version]
  end

  test "returns error for empty input" do
    result = Everyday::SslCertDecoderCalculator.new(pem_text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Certificate text cannot be empty"
  end

  test "returns error for non-PEM text" do
    result = Everyday::SslCertDecoderCalculator.new(pem_text: "this is not a certificate").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("-----BEGIN CERTIFICATE-----") }
  end

  test "returns error for invalid PEM content" do
    pem = "-----BEGIN CERTIFICATE-----\nnotvalidbase64content\n-----END CERTIFICATE-----"
    result = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid certificate") }
  end

  test "returns error for whitespace-only input" do
    result = Everyday::SslCertDecoderCalculator.new(pem_text: "   \n  ").call
    assert_not result[:valid]
    assert_includes result[:errors], "Certificate text cannot be empty"
  end

  test "fingerprints are consistent for same certificate" do
    pem = generate_test_cert
    result1 = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call
    result2 = Everyday::SslCertDecoderCalculator.new(pem_text: pem).call

    assert_equal result1[:fingerprints][:sha256], result2[:fingerprints][:sha256]
    assert_equal result1[:fingerprints][:sha1], result2[:fingerprints][:sha1]
  end
end
