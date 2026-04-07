require "test_helper"

class Everyday::MorseCodeCalculatorTest < ActiveSupport::TestCase
  test "translates text to morse code" do
    result = Everyday::MorseCodeCalculator.new(text: "SOS", direction: :to_morse).call
    assert result[:valid]
    assert_equal :to_morse, result[:direction]
    assert_equal "... --- ...", result[:output]
  end

  test "translates hello world to morse code" do
    result = Everyday::MorseCodeCalculator.new(text: "HELLO WORLD", direction: :to_morse).call
    assert result[:valid]
    assert_equal ".... . .-.. .-.. --- / .-- --- .-. .-.. -..", result[:output]
  end

  test "translates lowercase text to morse code" do
    result = Everyday::MorseCodeCalculator.new(text: "abc", direction: :to_morse).call
    assert result[:valid]
    assert_equal ".- -... -.-.", result[:output]
  end

  test "translates digits to morse code" do
    result = Everyday::MorseCodeCalculator.new(text: "123", direction: :to_morse).call
    assert result[:valid]
    assert_equal ".---- ..--- ...--", result[:output]
  end

  test "translates morse code to text" do
    result = Everyday::MorseCodeCalculator.new(text: "... --- ...", direction: :from_morse).call
    assert result[:valid]
    assert_equal :from_morse, result[:direction]
    assert_equal "SOS", result[:output]
  end

  test "translates morse code with word separators" do
    result = Everyday::MorseCodeCalculator.new(text: ".... . .-.. .-.. --- / .-- --- .-. .-.. -..", direction: :from_morse).call
    assert result[:valid]
    assert_equal "HELLO WORLD", result[:output]
  end

  test "handles unknown characters in text to morse" do
    result = Everyday::MorseCodeCalculator.new(text: "A~B", direction: :to_morse).call
    assert result[:valid]
    assert_includes result[:unknown_characters], "~"
  end

  test "handles unknown codes in morse to text" do
    result = Everyday::MorseCodeCalculator.new(text: ".- ........ -...", direction: :from_morse).call
    assert result[:valid]
    assert_includes result[:unknown_codes], "........"
  end

  test "returns character count for text to morse" do
    result = Everyday::MorseCodeCalculator.new(text: "ABC", direction: :to_morse).call
    assert result[:valid]
    assert_equal 3, result[:character_count]
  end

  test "translates punctuation to morse code" do
    result = Everyday::MorseCodeCalculator.new(text: ".", direction: :to_morse).call
    assert result[:valid]
    assert_equal ".-.-.-", result[:output]
  end

  test "returns error for empty text" do
    result = Everyday::MorseCodeCalculator.new(text: "", direction: :to_morse).call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for whitespace-only text" do
    result = Everyday::MorseCodeCalculator.new(text: "   ", direction: :to_morse).call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for text exceeding max length" do
    long_text = "A" * 5001
    result = Everyday::MorseCodeCalculator.new(text: long_text, direction: :to_morse).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("maximum length") }
  end

  test "accepts text at max length" do
    text = "A" * 5000
    result = Everyday::MorseCodeCalculator.new(text: text, direction: :to_morse).call
    assert result[:valid]
  end

  test "returns error for invalid direction" do
    result = Everyday::MorseCodeCalculator.new(text: "Hello", direction: :invalid).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid direction") }
  end

  test "handles space-only word separation in text" do
    result = Everyday::MorseCodeCalculator.new(text: "A B", direction: :to_morse).call
    assert result[:valid]
    assert_equal ".- / -...", result[:output]
  end

  test "roundtrip text to morse and back" do
    original = "HELLO"
    to_morse = Everyday::MorseCodeCalculator.new(text: original, direction: :to_morse).call
    from_morse = Everyday::MorseCodeCalculator.new(text: to_morse[:output], direction: :from_morse).call
    assert_equal original, from_morse[:output]
  end
end
