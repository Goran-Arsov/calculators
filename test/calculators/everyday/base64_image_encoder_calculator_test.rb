require "test_helper"

class Everyday::Base64ImageEncoderCalculatorTest < ActiveSupport::TestCase
  test "detects PNG format from base64" do
    # PNG starts with iVBOR
    png_b64 = Base64.strict_encode64("\x89PNG\r\n\x1a\n" + "\x00" * 100)
    result = Everyday::Base64ImageEncoderCalculator.new(base64: png_b64).call
    assert result[:valid]
    assert_equal "image/png", result[:format]
    assert_equal "image/png", result[:mime_type]
    assert_equal "data:image/png;base64,", result[:data_uri_prefix]
  end

  test "detects JPEG format from base64" do
    # JPEG starts with /9j/
    jpeg_b64 = "/9j/" + Base64.strict_encode64("\x00" * 100)
    result = Everyday::Base64ImageEncoderCalculator.new(base64: jpeg_b64).call
    assert result[:valid]
    assert_equal "image/jpeg", result[:format]
  end

  test "detects GIF format from base64" do
    gif_b64 = Base64.strict_encode64("GIF89a" + "\x00" * 100)
    result = Everyday::Base64ImageEncoderCalculator.new(base64: gif_b64).call
    assert result[:valid]
    assert_equal "image/gif", result[:format]
  end

  test "returns estimated file size" do
    data = Base64.strict_encode64("Hello World 1234")
    result = Everyday::Base64ImageEncoderCalculator.new(base64: data).call
    assert result[:valid]
    assert result[:estimated_file_size] > 0
    assert result[:estimated_file_size_display].is_a?(String)
  end

  test "returns base64 length" do
    data = Base64.strict_encode64("test data")
    result = Everyday::Base64ImageEncoderCalculator.new(base64: data).call
    assert result[:valid]
    assert_equal data.length, result[:base64_length]
  end

  test "strips data URI prefix before processing" do
    raw = Base64.strict_encode64("test image data here")
    data_uri = "data:image/png;base64,#{raw}"
    result = Everyday::Base64ImageEncoderCalculator.new(base64: data_uri).call
    assert result[:valid]
    assert_equal raw.length, result[:base64_length]
  end

  test "returns error for empty base64" do
    result = Everyday::Base64ImageEncoderCalculator.new(base64: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Base64 string cannot be empty"
  end

  test "returns error for invalid base64" do
    result = Everyday::Base64ImageEncoderCalculator.new(base64: "not-valid-base64!!!").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid Base64") }
  end

  test "returns unknown format for unrecognized data" do
    data = Base64.strict_encode64("just some random text here")
    result = Everyday::Base64ImageEncoderCalculator.new(base64: data).call
    assert result[:valid]
    assert_nil result[:format]
    assert_equal "application/octet-stream", result[:mime_type]
  end

  test "human file size displays bytes for small files" do
    data = Base64.strict_encode64("hi")
    result = Everyday::Base64ImageEncoderCalculator.new(base64: data).call
    assert result[:valid]
    assert_match(/B\z/, result[:estimated_file_size_display])
  end

  test "human file size displays KB for medium files" do
    data = Base64.strict_encode64("a" * 2000)
    result = Everyday::Base64ImageEncoderCalculator.new(base64: data).call
    assert result[:valid]
    assert_match(/KB\z/, result[:estimated_file_size_display])
  end
end
