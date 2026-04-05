require "test_helper"

class Everyday::CaseConverterCalculatorTest < ActiveSupport::TestCase
  test "converts to uppercase" do
    result = Everyday::CaseConverterCalculator.new(text: "hello world").call
    assert result[:valid]
    assert_equal "HELLO WORLD", result[:uppercase]
  end

  test "converts to lowercase" do
    result = Everyday::CaseConverterCalculator.new(text: "HELLO WORLD").call
    assert result[:valid]
    assert_equal "hello world", result[:lowercase]
  end

  test "converts to title case" do
    result = Everyday::CaseConverterCalculator.new(text: "hello world foo").call
    assert result[:valid]
    assert_equal "Hello World Foo", result[:title_case]
  end

  test "converts to sentence case" do
    result = Everyday::CaseConverterCalculator.new(text: "hello world. foo bar.").call
    assert result[:valid]
    assert_equal "Hello world. Foo bar.", result[:sentence_case]
  end

  test "converts to camelCase" do
    result = Everyday::CaseConverterCalculator.new(text: "hello world foo").call
    assert result[:valid]
    assert_equal "helloWorldFoo", result[:camel_case]
  end

  test "converts to snake_case" do
    result = Everyday::CaseConverterCalculator.new(text: "Hello World Foo").call
    assert result[:valid]
    assert_equal "hello_world_foo", result[:snake_case]
  end

  test "converts to kebab-case" do
    result = Everyday::CaseConverterCalculator.new(text: "Hello World Foo").call
    assert result[:valid]
    assert_equal "hello-world-foo", result[:kebab_case]
  end

  test "returns error for empty text" do
    result = Everyday::CaseConverterCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "handles single word" do
    result = Everyday::CaseConverterCalculator.new(text: "hello").call
    assert result[:valid]
    assert_equal "HELLO", result[:uppercase]
    assert_equal "Hello", result[:title_case]
    assert_equal "hello", result[:camel_case]
  end

  test "snake_case handles camelCase input" do
    result = Everyday::CaseConverterCalculator.new(text: "helloWorld").call
    assert result[:valid]
    assert_equal "hello_world", result[:snake_case]
  end

  test "kebab-case handles underscored input" do
    result = Everyday::CaseConverterCalculator.new(text: "hello_world").call
    assert result[:valid]
    assert_equal "hello-world", result[:kebab_case]
  end
end
