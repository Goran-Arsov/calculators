require "test_helper"

class Everyday::TailwindToCssCalculatorTest < ActiveSupport::TestCase
  test "converts flex to display: flex" do
    result = Everyday::TailwindToCssCalculator.new(tailwind_classes: "flex").call
    assert_equal true, result[:valid]
    assert_equal 1, result[:converted_count]
    assert result[:conversions].first[:css].include?("display: flex")
  end

  test "converts p-4 to padding: 1rem" do
    result = Everyday::TailwindToCssCalculator.new(tailwind_classes: "p-4").call
    assert_equal true, result[:valid]
    assert result[:conversions].first[:css].include?("padding: 1rem")
  end

  test "converts hidden to display: none" do
    result = Everyday::TailwindToCssCalculator.new(tailwind_classes: "hidden").call
    assert_equal true, result[:valid]
    assert result[:conversions].first[:css].include?("display: none")
  end

  test "converts multiple classes" do
    result = Everyday::TailwindToCssCalculator.new(tailwind_classes: "flex items-center p-4").call
    assert_equal true, result[:valid]
    assert_equal 3, result[:total_classes]
    assert_equal 3, result[:converted_count]
  end

  test "marks unknown classes as unconverted" do
    result = Everyday::TailwindToCssCalculator.new(tailwind_classes: "bg-blue-500").call
    assert_equal true, result[:valid]
    assert_equal 1, result[:unconverted_count]
  end

  test "converts font-bold to font-weight: 700" do
    result = Everyday::TailwindToCssCalculator.new(tailwind_classes: "font-bold").call
    assert_equal true, result[:valid]
    assert result[:conversions].first[:css].include?("font-weight: 700")
  end

  test "converts text-lg to correct font-size" do
    result = Everyday::TailwindToCssCalculator.new(tailwind_classes: "text-lg").call
    assert_equal true, result[:valid]
    assert result[:conversions].first[:css].include?("font-size: 1.125rem")
  end

  test "converts rounded-lg to border-radius" do
    result = Everyday::TailwindToCssCalculator.new(tailwind_classes: "rounded-lg").call
    assert_equal true, result[:valid]
    assert result[:conversions].first[:css].include?("border-radius: 0.5rem")
  end

  test "generates CSS output with .element selector" do
    result = Everyday::TailwindToCssCalculator.new(tailwind_classes: "flex").call
    assert result[:css_output].start_with?(".element {")
  end

  test "error when classes are empty" do
    result = Everyday::TailwindToCssCalculator.new(tailwind_classes: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Tailwind classes are required"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::TailwindToCssCalculator.new(tailwind_classes: "flex")
    assert_equal [], calc.errors
  end
end
