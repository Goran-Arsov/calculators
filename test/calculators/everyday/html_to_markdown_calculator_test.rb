require "test_helper"

class Everyday::HtmlToMarkdownCalculatorTest < ActiveSupport::TestCase
  # --- Headings ---

  test "converts h1" do
    result = calc("<h1>Title</h1>").call
    assert result[:valid]
    assert_includes result[:markdown], "# Title"
  end

  test "converts h3" do
    result = calc("<h3>Section</h3>").call
    assert result[:valid]
    assert_includes result[:markdown], "### Section"
  end

  # --- Inline formatting ---

  test "converts strong to bold" do
    result = calc("<p>This is <strong>bold</strong> text</p>").call
    assert result[:valid]
    assert_includes result[:markdown], "**bold**"
  end

  test "converts em to italic" do
    result = calc("<p>This is <em>italic</em> text</p>").call
    assert result[:valid]
    assert_includes result[:markdown], "*italic*"
  end

  test "converts del to strikethrough" do
    result = calc("<p>This is <del>deleted</del> text</p>").call
    assert result[:valid]
    assert_includes result[:markdown], "~~deleted~~"
  end

  test "converts inline code" do
    result = calc("<p>Use <code>puts</code> here</p>").call
    assert result[:valid]
    assert_includes result[:markdown], "`puts`"
  end

  # --- Links and images ---

  test "converts link" do
    result = calc('<a href="https://example.com">Click</a>').call
    assert result[:valid]
    assert_includes result[:markdown], "[Click](https://example.com)"
  end

  test "converts image" do
    result = calc('<img src="photo.jpg" alt="A photo">').call
    assert result[:valid]
    assert_includes result[:markdown], "![A photo](photo.jpg)"
  end

  # --- Lists ---

  test "converts unordered list" do
    result = calc("<ul><li>One</li><li>Two</li></ul>").call
    assert result[:valid]
    assert_includes result[:markdown], "- One"
    assert_includes result[:markdown], "- Two"
  end

  test "converts ordered list" do
    result = calc("<ol><li>First</li><li>Second</li></ol>").call
    assert result[:valid]
    assert_includes result[:markdown], "1. First"
    assert_includes result[:markdown], "2. Second"
  end

  # --- Code blocks ---

  test "converts pre/code to fenced code block" do
    result = calc("<pre><code>var x = 1</code></pre>").call
    assert result[:valid]
    assert_includes result[:markdown], "```"
    assert_includes result[:markdown], "var x = 1"
  end

  test "converts pre/code with language class" do
    result = calc('<pre><code class="language-python">print("hi")</code></pre>').call
    assert result[:valid]
    assert_includes result[:markdown], "```python"
  end

  # --- Block elements ---

  test "converts blockquote" do
    result = calc("<blockquote><p>Quoted text</p></blockquote>").call
    assert result[:valid]
    assert_includes result[:markdown], "> Quoted text"
  end

  test "converts hr" do
    result = calc("<hr>").call
    assert result[:valid]
    assert_includes result[:markdown], "---"
  end

  test "converts paragraph" do
    result = calc("<p>Hello world</p>").call
    assert result[:valid]
    assert_includes result[:markdown], "Hello world"
  end

  # --- Table ---

  test "converts simple table" do
    html = "<table><tr><th>Name</th><th>Age</th></tr><tr><td>Alice</td><td>30</td></tr></table>"
    result = calc(html).call
    assert result[:valid]
    assert_includes result[:markdown], "| Name | Age |"
    assert_includes result[:markdown], "| --- | --- |"
    assert_includes result[:markdown], "| Alice | 30 |"
  end

  # --- Nested elements ---

  test "handles bold inside heading" do
    result = calc("<h2>This is <strong>important</strong></h2>").call
    assert result[:valid]
    assert_includes result[:markdown], "## This is **important**"
  end

  # --- Metadata ---

  test "returns input and output lengths" do
    result = calc("<p>Hello</p>").call
    assert result[:valid]
    assert result[:input_length] > 0
    assert result[:output_length] > 0
  end

  # --- Validation ---

  test "error when input is empty" do
    result = calc("").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "HTML text cannot be empty"
  end

  test "error when input is whitespace" do
    result = calc("   ").call
    assert_equal false, result[:valid]
  end

  private

  def calc(html)
    Everyday::HtmlToMarkdownCalculator.new(html: html)
  end
end
