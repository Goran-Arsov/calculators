require "test_helper"

class Everyday::CookingConverterTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "1 cup → ~236.588 ml" do
    result = Everyday::CookingConverter.new(conversion: "cups_to_ml", value: 1).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 236.588, result[:result]
    assert_equal "cups", result[:from_unit]
    assert_equal "ml", result[:to_unit]
  end

  test "1 tbsp → ~14.787 ml" do
    result = Everyday::CookingConverter.new(conversion: "tbsp_to_ml", value: 1).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 14.787, result[:result]
  end

  test "1 oz → ~28.3495 g" do
    result = Everyday::CookingConverter.new(conversion: "oz_to_g", value: 1).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 28.3495, result[:result]
  end

  test "1 lb → ~0.4536 kg" do
    result = Everyday::CookingConverter.new(conversion: "lb_to_kg", value: 1).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_in_delta 0.4536, result[:result], 0.001
  end

  # --- Validation errors ---

  test "error when value is zero" do
    result = Everyday::CookingConverter.new(conversion: "cups_to_ml", value: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Value must be greater than zero"
  end

  test "error with unknown conversion" do
    result = Everyday::CookingConverter.new(conversion: "invalid_conv", value: 1).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown conversion") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::CookingConverter.new(conversion: "cups_to_ml", value: 1)
    assert_equal [], calc.errors
  end
end
