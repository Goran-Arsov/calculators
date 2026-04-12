require "test_helper"

class Relationships::ZodiacCompatibilityCalculatorTest < ActiveSupport::TestCase
  test "complementary elements score high" do
    result = Relationships::ZodiacCompatibilityCalculator.new(sign1: "leo", sign2: "aquarius").call
    assert result[:valid]
    assert result[:overall] >= 85
  end

  test "same sign gives bonus" do
    result = Relationships::ZodiacCompatibilityCalculator.new(sign1: "taurus", sign2: "taurus").call
    assert result[:valid]
    assert result[:overall] >= 80
  end

  test "invalid sign errors" do
    result = Relationships::ZodiacCompatibilityCalculator.new(sign1: "spaghetti", sign2: "leo").call
    assert_equal false, result[:valid]
  end

  test "result includes love friendship and communication" do
    result = Relationships::ZodiacCompatibilityCalculator.new(sign1: "gemini", sign2: "libra").call
    assert result[:love].is_a?(Integer)
    assert result[:friendship].is_a?(Integer)
    assert result[:communication].is_a?(Integer)
  end
end
