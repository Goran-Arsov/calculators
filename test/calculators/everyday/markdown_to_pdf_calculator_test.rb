require "test_helper"

class Everyday::MarkdownToPdfCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "returns valid result with line count, word count, heading count, and code block count" do
    md = "# Hello World\n\nThis is a paragraph with several words.\n\n## Section Two\n\n```\ncode here\n```"
    result = calc(md).call

    assert result[:valid]
    assert result[:line_count] > 0
    assert result[:word_count] > 0
    assert result[:heading_count] > 0
    assert result[:code_block_count] > 0
  end

  test "counts words correctly" do
    result = calc("one two three four five").call
    assert result[:valid]
    assert_equal 5, result[:word_count]
  end

  test "counts lines correctly" do
    result = calc("line one\nline two\nline three").call
    assert result[:valid]
    assert_equal 3, result[:line_count]
  end

  # --- Headings ---

  test "markdown with headings returns heading count greater than zero" do
    md = "# First\n## Second\n### Third"
    result = calc(md).call

    assert result[:valid]
    assert_equal 3, result[:heading_count]
  end

  test "counts only valid headings with space after hash" do
    md = "# Valid heading\n#Not a heading\n## Another valid"
    result = calc(md).call

    assert result[:valid]
    assert_equal 2, result[:heading_count]
  end

  test "counts all heading levels h1 through h6" do
    md = "# H1\n## H2\n### H3\n#### H4\n##### H5\n###### H6"
    result = calc(md).call

    assert result[:valid]
    assert_equal 6, result[:heading_count]
  end

  # --- Code blocks ---

  test "markdown with code blocks returns code block count greater than zero" do
    md = "Some text\n\n```\nputs 'hello'\n```\n\nMore text\n\n```ruby\nclass Foo; end\n```"
    result = calc(md).call

    assert result[:valid]
    assert_equal 2, result[:code_block_count]
  end

  test "single code block counted correctly" do
    md = "```\nvar x = 1\n```"
    result = calc(md).call

    assert result[:valid]
    assert_equal 1, result[:code_block_count]
  end

  test "unclosed code block counts as zero" do
    md = "```\nsome code without closing"
    result = calc(md).call

    assert result[:valid]
    assert_equal 0, result[:code_block_count]
  end

  # --- Plain paragraph ---

  test "plain text returns zero headings and zero code blocks" do
    result = calc("Just a plain paragraph of text.").call

    assert result[:valid]
    assert_equal 0, result[:heading_count]
    assert_equal 0, result[:code_block_count]
  end

  # --- Error cases ---

  test "empty input returns error" do
    result = calc("").call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Markdown text cannot be empty"
  end

  test "whitespace-only input returns error" do
    result = calc("   \n  \t  ").call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Markdown text cannot be empty"
  end

  test "nil input returns error" do
    result = calc(nil).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Markdown text cannot be empty"
  end

  private

  def calc(md)
    Everyday::MarkdownToPdfCalculator.new(markdown: md)
  end
end
