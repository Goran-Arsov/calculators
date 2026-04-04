require "test_helper"

class Finance::MarkupMarginCalculatorTest < ActiveSupport::TestCase
  # --- Markup to margin ---

  test "markup 100% → margin 50%" do
    result = Finance::MarkupMarginCalculator.new(mode: "markup_to_margin", value: 100).call
    assert result[:valid]
    assert_equal 50.0, result[:margin]
    assert_equal 100.0, result[:markup]
    assert_equal "markup_to_margin", result[:mode]
  end

  test "markup 50% → margin 33.3333%" do
    result = Finance::MarkupMarginCalculator.new(mode: "markup_to_margin", value: 50).call
    assert result[:valid]
    assert_in_delta 33.3333, result[:margin], 0.001
  end

  test "markup 0% → margin 0%" do
    result = Finance::MarkupMarginCalculator.new(mode: "markup_to_margin", value: 0).call
    assert result[:valid]
    assert_equal 0.0, result[:margin]
  end

  # --- Margin to markup ---

  test "margin 50% → markup 100%" do
    result = Finance::MarkupMarginCalculator.new(mode: "margin_to_markup", value: 50).call
    assert result[:valid]
    assert_equal 100.0, result[:markup]
    assert_equal 50.0, result[:margin]
    assert_equal "margin_to_markup", result[:mode]
  end

  # --- Validation errors ---

  test "error with invalid mode" do
    result = Finance::MarkupMarginCalculator.new(mode: "invalid", value: 50).call
    refute result[:valid]
    assert_includes result[:errors], "Mode must be markup_to_margin or margin_to_markup"
  end

  test "error when margin is 100% or more" do
    result = Finance::MarkupMarginCalculator.new(mode: "margin_to_markup", value: 100).call
    refute result[:valid]
    assert_includes result[:errors], "Margin percentage must be less than 100%"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::MarkupMarginCalculator.new(mode: "markup_to_margin", value: 50)
    assert_equal [], calc.errors
  end
end
