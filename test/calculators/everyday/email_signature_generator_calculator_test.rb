require "test_helper"

class Everyday::EmailSignatureGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates professional signature" do
    result = Everyday::EmailSignatureGeneratorCalculator.new(
      full_name: "Jane Smith", job_title: "Developer", company: "Acme"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:html], "Jane Smith"
    assert_includes result[:html], "Developer"
    assert_includes result[:html], "Acme"
    assert_equal "professional", result[:template]
  end

  test "generates minimal signature" do
    result = Everyday::EmailSignatureGeneratorCalculator.new(
      full_name: "Jane Smith", template: "minimal"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:html], "Jane Smith"
    assert_equal "minimal", result[:template]
  end

  test "generates modern signature" do
    result = Everyday::EmailSignatureGeneratorCalculator.new(
      full_name: "Jane Smith", template: "modern"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:html], "Jane Smith"
  end

  test "generates colorful signature" do
    result = Everyday::EmailSignatureGeneratorCalculator.new(
      full_name: "Jane Smith", template: "colorful"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:html], "Jane Smith"
  end

  test "includes email link" do
    result = Everyday::EmailSignatureGeneratorCalculator.new(
      full_name: "Jane Smith", email: "jane@example.com"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:html], "mailto:jane@example.com"
  end

  test "includes social links" do
    result = Everyday::EmailSignatureGeneratorCalculator.new(
      full_name: "Jane Smith", linkedin: "linkedin.com/in/jane"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:html], "LinkedIn"
  end

  test "uses custom primary color" do
    result = Everyday::EmailSignatureGeneratorCalculator.new(
      full_name: "Jane Smith", primary_color: "#FF0000"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:html], "#FF0000"
  end

  test "error when name is empty" do
    result = Everyday::EmailSignatureGeneratorCalculator.new(full_name: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Full name is required"
  end

  test "error for invalid template" do
    result = Everyday::EmailSignatureGeneratorCalculator.new(full_name: "Jane", template: "nonexistent").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid template") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::EmailSignatureGeneratorCalculator.new(full_name: "Jane")
    assert_equal [], calc.errors
  end
end
