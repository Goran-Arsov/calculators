require "test_helper"

class Everyday::HtmlToJsxCalculatorTest < ActiveSupport::TestCase
  test "converts class to className" do
    result = Everyday::HtmlToJsxCalculator.new(html: '<div class="container">Hello</div>').call
    assert result[:valid]
    assert_includes result[:jsx], "className"
    assert_not_includes result[:jsx], " class="
  end

  test "converts for to htmlFor" do
    result = Everyday::HtmlToJsxCalculator.new(html: '<label for="name">Name</label>').call
    assert result[:valid]
    assert_includes result[:jsx], "htmlFor"
  end

  test "self-closes void elements" do
    result = Everyday::HtmlToJsxCalculator.new(html: '<img src="test.png">').call
    assert result[:valid]
    assert_includes result[:jsx], "/>"
  end

  test "converts inline styles to objects" do
    result = Everyday::HtmlToJsxCalculator.new(html: '<div style="color: red; font-size: 14px">Hello</div>').call
    assert result[:valid]
    assert_includes result[:jsx], "style={{color: 'red', fontSize: '14px'}}"
  end

  test "converts HTML comments to JSX comments" do
    result = Everyday::HtmlToJsxCalculator.new(html: "<!-- comment -->").call
    assert result[:valid]
    assert_includes result[:jsx], "{/*"
    assert_includes result[:jsx], "*/}"
  end

  test "converts event handlers to camelCase" do
    result = Everyday::HtmlToJsxCalculator.new(html: '<button onclick="handleClick()">Click</button>').call
    assert result[:valid]
    assert_includes result[:jsx], "onClick"
  end

  test "converts tabindex to tabIndex" do
    result = Everyday::HtmlToJsxCalculator.new(html: '<div tabindex="0">Focusable</div>').call
    assert result[:valid]
    assert_includes result[:jsx], "tabIndex"
  end

  test "counts changes made" do
    result = Everyday::HtmlToJsxCalculator.new(html: '<div class="a"><img src="b"></div>').call
    assert result[:valid]
    assert result[:changes_made] > 0
  end

  test "returns error for empty HTML" do
    result = Everyday::HtmlToJsxCalculator.new(html: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "HTML cannot be empty"
  end

  test "preserves already-valid JSX" do
    jsx = '<div className="container">Hello</div>'
    result = Everyday::HtmlToJsxCalculator.new(html: jsx).call
    assert result[:valid]
    assert_includes result[:jsx], 'className="container"'
  end
end
