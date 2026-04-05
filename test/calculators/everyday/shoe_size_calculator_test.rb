require "test_helper"

class Everyday::ShoeSizeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "US 10 converts to UK 9.5, EU 43, CM 26.0" do
    result = Everyday::ShoeSizeCalculator.new(size: 10, system: "US").call
    assert_nil result[:errors]
    assert_equal 10.0, result[:us]
    assert_equal 9.5, result[:uk]
    assert_equal 43.0, result[:eu]
    assert_equal 26.0, result[:cm]
  end

  test "EU 42 converts to US 9, UK 8.5, CM 25.4" do
    result = Everyday::ShoeSizeCalculator.new(size: 42, system: "EU").call
    assert_nil result[:errors]
    assert_equal 9.0, result[:us]
    assert_equal 8.5, result[:uk]
    assert_equal 42.0, result[:eu]
    assert_equal 25.4, result[:cm]
  end

  test "UK 7 converts correctly" do
    result = Everyday::ShoeSizeCalculator.new(size: 7.0, system: "UK").call
    assert_nil result[:errors]
    assert_equal 7.5, result[:us]
    assert_equal 7.0, result[:uk]
    assert_equal 40.0, result[:eu]
  end

  test "CM 25.4 converts to US 9" do
    result = Everyday::ShoeSizeCalculator.new(size: 25.4, system: "CM").call
    assert_nil result[:errors]
    assert_equal 9.0, result[:us]
    assert_equal 25.4, result[:cm]
  end

  test "closest match for in-between size" do
    result = Everyday::ShoeSizeCalculator.new(size: 9.2, system: "US").call
    assert_nil result[:errors]
    # 9.2 is closest to 9.0 (diff 0.2) vs 9.5 (diff 0.3)
    assert_equal 9.0, result[:us]
  end

  test "smallest size in table" do
    result = Everyday::ShoeSizeCalculator.new(size: 3.5, system: "US").call
    assert_nil result[:errors]
    assert_equal 3.5, result[:us]
    assert_equal 35.5, result[:eu]
  end

  test "largest size in table" do
    result = Everyday::ShoeSizeCalculator.new(size: 15, system: "US").call
    assert_nil result[:errors]
    assert_equal 15.0, result[:us]
    assert_equal 48.5, result[:eu]
  end

  # --- Validation errors ---

  test "error when size is zero" do
    result = Everyday::ShoeSizeCalculator.new(size: 0, system: "US").call
    assert result[:errors].any?
    assert_includes result[:errors], "Size must be greater than zero"
  end

  test "error when size is negative" do
    result = Everyday::ShoeSizeCalculator.new(size: -5, system: "EU").call
    assert result[:errors].any?
    assert_includes result[:errors], "Size must be greater than zero"
  end

  test "error for unknown system" do
    result = Everyday::ShoeSizeCalculator.new(size: 10, system: "JP").call
    assert result[:errors].any?
    assert result[:errors].any? { |e| e.include?("Unknown sizing system") }
  end

  test "string coercion for size" do
    result = Everyday::ShoeSizeCalculator.new(size: "10", system: "US").call
    assert_nil result[:errors]
    assert_equal 10.0, result[:us]
  end

  test "system is case-insensitive" do
    result = Everyday::ShoeSizeCalculator.new(size: 10, system: "us").call
    assert_nil result[:errors]
    assert_equal 10.0, result[:us]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::ShoeSizeCalculator.new(size: 10, system: "US")
    assert_equal [], calc.errors
  end
end
