require "test_helper"

class Everyday::DiffViewerCalculatorTest < ActiveSupport::TestCase
  test "identical texts produce no additions or deletions" do
    result = Everyday::DiffViewerCalculator.new(text_a: "hello\nworld", text_b: "hello\nworld").call
    assert_equal true, result[:valid]
    assert_equal 0, result[:additions]
    assert_equal 0, result[:deletions]
    assert_equal 2, result[:unchanged]
  end

  test "detects additions in second text" do
    result = Everyday::DiffViewerCalculator.new(text_a: "hello", text_b: "hello\nworld").call
    assert_equal true, result[:valid]
    assert_equal 1, result[:additions]
    assert_equal 0, result[:deletions]
    assert_equal 1, result[:unchanged]
  end

  test "detects deletions from first text" do
    result = Everyday::DiffViewerCalculator.new(text_a: "hello\nworld", text_b: "hello").call
    assert_equal true, result[:valid]
    assert_equal 0, result[:additions]
    assert_equal 1, result[:deletions]
    assert_equal 1, result[:unchanged]
  end

  test "detects mixed changes" do
    result = Everyday::DiffViewerCalculator.new(text_a: "a\nb\nc", text_b: "a\nx\nc").call
    assert_equal true, result[:valid]
    assert result[:additions] >= 1
    assert result[:deletions] >= 1
    assert result[:unchanged] >= 1
  end

  test "handles empty first text" do
    result = Everyday::DiffViewerCalculator.new(text_a: "", text_b: "hello\nworld").call
    assert_equal true, result[:valid]
    assert_equal 2, result[:additions]
    assert_equal 0, result[:deletions]
  end

  test "handles empty second text" do
    result = Everyday::DiffViewerCalculator.new(text_a: "hello\nworld", text_b: "").call
    assert_equal true, result[:valid]
    assert_equal 0, result[:additions]
    assert_equal 2, result[:deletions]
  end

  test "error when both texts are empty" do
    result = Everyday::DiffViewerCalculator.new(text_a: "", text_b: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Both text fields must be provided"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::DiffViewerCalculator.new(text_a: "a", text_b: "b")
    assert_equal [], calc.errors
  end
end
