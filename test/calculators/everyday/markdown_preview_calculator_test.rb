require "test_helper"

class Everyday::MarkdownPreviewCalculatorTest < ActiveSupport::TestCase
  test "converts headings" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "# Hello\n## World").call
    assert result[:valid]
    assert_includes result[:html], "<h1>Hello</h1>"
    assert_includes result[:html], "<h2>World</h2>"
  end

  test "converts bold text" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "This is **bold** text").call
    assert result[:valid]
    assert_includes result[:html], "<strong>bold</strong>"
  end

  test "converts italic text" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "This is *italic* text").call
    assert result[:valid]
    assert_includes result[:html], "<em>italic</em>"
  end

  test "converts links" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "Click [here](https://example.com)").call
    assert result[:valid]
    assert_includes result[:html], '<a href="https://example.com">here</a>'
  end

  test "converts unordered lists" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "- Item 1\n- Item 2\n- Item 3").call
    assert result[:valid]
    assert_includes result[:html], "<ul>"
    assert_includes result[:html], "<li>Item 1</li>"
    assert_includes result[:html], "</ul>"
  end

  test "converts ordered lists" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "1. First\n2. Second").call
    assert result[:valid]
    assert_includes result[:html], "<ol>"
    assert_includes result[:html], "<li>First</li>"
  end

  test "converts code blocks" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "```\ncode here\n```").call
    assert result[:valid]
    assert_includes result[:html], "<pre><code>"
    assert_includes result[:html], "code here"
    assert_includes result[:html], "</code></pre>"
  end

  test "converts inline code" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "Use the `puts` method").call
    assert result[:valid]
    assert_includes result[:html], "<code>puts</code>"
  end

  test "returns error for empty text" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "counts words and lines" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "Hello world\nFoo bar baz").call
    assert result[:valid]
    assert_equal 5, result[:word_count]
    assert_equal 2, result[:line_count]
  end

  test "counts headings" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "# One\n## Two\n### Three\nParagraph").call
    assert result[:valid]
    assert_equal 3, result[:heading_count]
  end

  test "escapes HTML in regular text" do
    result = Everyday::MarkdownPreviewCalculator.new(text: "Use <div> tags").call
    assert result[:valid]
    assert_includes result[:html], "&lt;div&gt;"
  end
end
