require "test_helper"

class Everyday::MarkdownToHtmlCalculatorTest < ActiveSupport::TestCase
  # --- Headings ---

  test "converts h1 heading" do
    result = calc("# Hello").call
    assert result[:valid]
    assert_includes result[:html], "<h1>Hello</h1>"
  end

  test "converts h3 heading" do
    result = calc("### Third level").call
    assert result[:valid]
    assert_includes result[:html], "<h3>Third level</h3>"
  end

  # --- Inline formatting ---

  test "converts bold text" do
    result = calc("This is **bold** text").call
    assert result[:valid]
    assert_includes result[:html], "<strong>bold</strong>"
  end

  test "converts italic text" do
    result = calc("This is *italic* text").call
    assert result[:valid]
    assert_includes result[:html], "<em>italic</em>"
  end

  test "converts bold italic text" do
    result = calc("This is ***bold italic*** text").call
    assert result[:valid]
    assert_includes result[:html], "<strong><em>bold italic</em></strong>"
  end

  test "converts inline code" do
    result = calc("Use `console.log` here").call
    assert result[:valid]
    assert_includes result[:html], "<code>console.log</code>"
  end

  test "converts strikethrough" do
    result = calc("This is ~~deleted~~ text").call
    assert result[:valid]
    assert_includes result[:html], "<del>deleted</del>"
  end

  # --- Links and images ---

  test "converts link" do
    result = calc("[Click here](https://example.com)").call
    assert result[:valid]
    assert_includes result[:html], '<a href="https://example.com">Click here</a>'
  end

  test "converts image" do
    result = calc("![Alt text](image.png)").call
    assert result[:valid]
    assert_includes result[:html], '<img src="image.png" alt="Alt text">'
  end

  # --- Lists ---

  test "converts unordered list" do
    result = calc("- Item one\n- Item two\n- Item three").call
    assert result[:valid]
    assert_includes result[:html], "<ul>"
    assert_includes result[:html], "<li>Item one</li>"
    assert_includes result[:html], "<li>Item three</li>"
  end

  test "converts ordered list" do
    result = calc("1. First\n2. Second\n3. Third").call
    assert result[:valid]
    assert_includes result[:html], "<ol>"
    assert_includes result[:html], "<li>First</li>"
  end

  # --- Code blocks ---

  test "converts fenced code block" do
    result = calc("```\nvar x = 1\n```").call
    assert result[:valid]
    assert_includes result[:html], "<pre><code>"
    assert_includes result[:html], "var x = 1"
  end

  test "converts fenced code block with language" do
    result = calc("```ruby\nputs 'hello'\n```").call
    assert result[:valid]
    assert_includes result[:html], 'class="language-ruby"'
  end

  # --- Block elements ---

  test "converts blockquote" do
    result = calc("> This is quoted").call
    assert result[:valid]
    assert_includes result[:html], "<blockquote>"
    assert_includes result[:html], "This is quoted"
  end

  test "converts horizontal rule" do
    result = calc("---").call
    assert result[:valid]
    assert_includes result[:html], "<hr>"
  end

  test "converts paragraph" do
    result = calc("Just a paragraph of text.").call
    assert result[:valid]
    assert_includes result[:html], "<p>Just a paragraph of text.</p>"
  end

  # --- HTML escaping ---

  test "escapes HTML in content" do
    result = calc("Use <script> tags").call
    assert result[:valid]
    assert_includes result[:html], "&lt;script&gt;"
    refute_includes result[:html], "<script>"
  end

  # --- Metadata ---

  test "returns input and output lengths" do
    result = calc("# Hello").call
    assert result[:valid]
    assert_equal 7, result[:input_length]
    assert result[:output_length] > 0
  end

  # --- Validation ---

  test "error when input is empty" do
    result = calc("").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Markdown text cannot be empty"
  end

  test "error when input is whitespace" do
    result = calc("   \n  ").call
    assert_equal false, result[:valid]
  end

  private

  def calc(md)
    Everyday::MarkdownToHtmlCalculator.new(markdown: md)
  end
end
