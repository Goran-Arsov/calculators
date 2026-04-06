require "test_helper"

class Everyday::CspBuilderCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "builds a simple CSP header with default-src" do
    result = Everyday::CspBuilderCalculator.new(
      directives: { default_src: ["'self'"] }
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "default-src 'self'", result[:header]
    assert_equal 1, result[:directive_count]
  end

  test "builds header with multiple directives" do
    result = Everyday::CspBuilderCalculator.new(
      directives: {
        default_src: ["'self'"],
        script_src: ["'self'", "https://cdn.example.com"],
        style_src: ["'self'", "'unsafe-inline'"],
        img_src: ["*"]
      }
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 4, result[:directive_count]
    assert_includes result[:header], "default-src 'self'"
    assert_includes result[:header], "script-src 'self' https://cdn.example.com"
    assert_includes result[:header], "style-src 'self' 'unsafe-inline'"
    assert_includes result[:header], "img-src *"
  end

  test "accepts string sources instead of arrays" do
    result = Everyday::CspBuilderCalculator.new(
      directives: { default_src: "'self' https:" }
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "default-src 'self' https:", result[:header]
  end

  test "handles all supported directives" do
    directives = {}
    Everyday::CspBuilderCalculator::VALID_DIRECTIVES.each do |d|
      directives[d.tr("-", "_")] = ["'self'"]
    end
    result = Everyday::CspBuilderCalculator.new(directives: directives).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal Everyday::CspBuilderCalculator::VALID_DIRECTIVES.size, result[:directive_count]
  end

  test "ignores invalid directives" do
    result = Everyday::CspBuilderCalculator.new(
      directives: {
        default_src: ["'self'"],
        fake_directive: ["'none'"]
      }
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1, result[:directive_count]
    refute_includes result[:header], "fake-directive"
  end

  test "strips empty sources from directives" do
    result = Everyday::CspBuilderCalculator.new(
      directives: { default_src: ["'self'", "", "  "] }
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "default-src 'self'", result[:header]
  end

  test "returns directive hash in result" do
    result = Everyday::CspBuilderCalculator.new(
      directives: { script_src: ["'self'", "https:"] }
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal({"script-src" => ["'self'", "https:"]}, result[:directives])
  end

  test "separates directives with semicolons" do
    result = Everyday::CspBuilderCalculator.new(
      directives: {
        default_src: ["'none'"],
        script_src: ["'self'"]
      }
    ).call
    assert_includes result[:header], "; "
  end

  test "report_uri directive works" do
    result = Everyday::CspBuilderCalculator.new(
      directives: {
        default_src: ["'self'"],
        report_uri: ["/csp-report"]
      }
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_includes result[:header], "report-uri /csp-report"
  end

  # --- Validation errors ---

  test "error when no directives provided" do
    result = Everyday::CspBuilderCalculator.new(directives: {}).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one directive must be specified"
  end

  test "error when all directive values are empty" do
    result = Everyday::CspBuilderCalculator.new(
      directives: { default_src: [] }
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one directive must be specified"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::CspBuilderCalculator.new(directives: { default_src: ["'self'"] })
    assert_equal [], calc.errors
  end
end
