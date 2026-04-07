require "test_helper"

class Everyday::RegexExplainerCalculatorTest < ActiveSupport::TestCase
  test "explains literal characters" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "abc").call
    assert result[:valid]
    assert_equal 3, result[:token_count]
    assert result[:tokens].all? { |t| t[:explanation].include?("Literal") }
  end

  test "explains character classes" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "\\d\\w\\s").call
    assert result[:valid]
    assert_equal 3, result[:token_count]
    assert result[:tokens][0][:explanation].include?("digit")
    assert result[:tokens][1][:explanation].include?("word character")
    assert result[:tokens][2][:explanation].include?("whitespace")
  end

  test "explains quantifiers" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "a*b+c?").call
    assert result[:valid]
    assert result[:has_quantifiers]
    assert result[:tokens].any? { |t| t[:explanation].include?("Zero or more") }
    assert result[:tokens].any? { |t| t[:explanation].include?("One or more") }
    assert result[:tokens].any? { |t| t[:explanation].include?("Optional") }
  end

  test "explains anchors" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "^hello$").call
    assert result[:valid]
    assert result[:has_anchors]
    assert result[:tokens].first[:explanation].include?("Start")
    assert result[:tokens].last[:explanation].include?("End")
  end

  test "explains character sets" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "[a-z]").call
    assert result[:valid]
    assert result[:tokens].first[:explanation].include?("character in")
  end

  test "explains negated character sets" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "[^0-9]").call
    assert result[:valid]
    assert result[:tokens].first[:explanation].include?("NOT")
  end

  test "explains capturing groups" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "(abc)").call
    assert result[:valid]
    assert result[:has_groups]
    assert result[:tokens].first[:explanation].include?("Capturing group")
  end

  test "explains non-capturing groups" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "(?:abc)").call
    assert result[:valid]
    assert result[:tokens].first[:explanation].include?("Non-capturing")
  end

  test "explains lookahead" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "(?=abc)").call
    assert result[:valid]
    assert result[:tokens].first[:explanation].include?("lookahead")
  end

  test "explains curly brace quantifiers" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "a{3}b{2,5}c{1,}").call
    assert result[:valid]
    assert result[:tokens].any? { |t| t[:explanation].include?("Exactly 3") }
    assert result[:tokens].any? { |t| t[:explanation].include?("Between 2 and 5") }
    assert result[:tokens].any? { |t| t[:explanation].include?("1 or more") }
  end

  test "explains alternation" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "cat|dog").call
    assert result[:valid]
    assert result[:tokens].any? { |t| t[:explanation].include?("OR") }
  end

  test "returns error for empty pattern" do
    result = Everyday::RegexExplainerCalculator.new(pattern: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Pattern cannot be empty"
  end
end
