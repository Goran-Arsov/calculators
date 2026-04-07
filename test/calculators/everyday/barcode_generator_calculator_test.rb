require "test_helper"

class Everyday::BarcodeGeneratorCalculatorTest < ActiveSupport::TestCase
  test "validates code128 with valid ASCII text" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "Hello World 123", format: "code128").call
    assert result[:valid]
    assert_equal "Hello World 123", result[:text]
    assert_equal "code128", result[:format]
    assert_equal 15, result[:character_count]
  end

  test "validates code128 with special characters" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "ABC-123/456", format: "code128").call
    assert result[:valid]
  end

  test "rejects code128 with non-ASCII characters" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "Hello\x01", format: "code128").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("ASCII characters 32-127") }
  end

  test "validates ean13 with 12 digits" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "590123412345", format: "ean13").call
    assert result[:valid]
    assert_equal "ean13", result[:format]
  end

  test "validates ean13 with 13 digits" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "5901234123457", format: "ean13").call
    assert result[:valid]
  end

  test "rejects ean13 with letters" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "59012341234A", format: "ean13").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("12 or 13 digits") }
  end

  test "rejects ean13 with wrong length" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "12345", format: "ean13").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("12 or 13 digits") }
  end

  test "validates code39 with uppercase letters and digits" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "HELLO-123", format: "code39").call
    assert result[:valid]
    assert_equal "code39", result[:format]
  end

  test "validates code39 with special characters" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "A-B.C $D/E+F%G", format: "code39").call
    assert result[:valid]
  end

  test "rejects code39 with lowercase letters" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "hello", format: "code39").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("does not support") }
  end

  test "rejects code39 with invalid characters" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "ABC@123", format: "code39").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("does not support") }
  end

  test "returns error for empty text" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "", format: "code128").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for whitespace-only text" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "   ", format: "code128").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for text exceeding max length" do
    long_text = "A" * 501
    result = Everyday::BarcodeGeneratorCalculator.new(text: long_text, format: "code128").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("maximum length") }
  end

  test "accepts text at max length" do
    text = "A" * 500
    result = Everyday::BarcodeGeneratorCalculator.new(text: text, format: "code128").call
    assert result[:valid]
    assert_equal 500, result[:character_count]
  end

  test "returns error for unsupported format" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "Hello", format: "qr").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported format") }
  end

  test "code39 allows spaces" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "HELLO WORLD", format: "code39").call
    assert result[:valid]
  end

  test "code128 with all printable ASCII" do
    text = (32..127).map(&:chr).join
    result = Everyday::BarcodeGeneratorCalculator.new(text: text, format: "code128").call
    assert result[:valid]
  end

  test "ean13 with exactly 12 digits boundary" do
    result = Everyday::BarcodeGeneratorCalculator.new(text: "000000000000", format: "ean13").call
    assert result[:valid]
  end
end
