require "test_helper"

class Everyday::XmlToJsonCalculatorTest < ActiveSupport::TestCase
  test "converts simple XML to JSON" do
    xml = "<person><name>John</name><age>30</age></person>"
    result = Everyday::XmlToJsonCalculator.new(text: xml).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal "John", parsed["person"]["name"]
    assert_equal "30", parsed["person"]["age"]
  end

  test "handles XML attributes with @ prefix" do
    xml = '<book id="1" category="fiction"><title>Gatsby</title></book>'
    result = Everyday::XmlToJsonCalculator.new(text: xml).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal "1", parsed["book"]["@id"]
    assert_equal "fiction", parsed["book"]["@category"]
    assert_equal "Gatsby", parsed["book"]["title"]
  end

  test "converts repeated elements to arrays" do
    xml = "<list><item>A</item><item>B</item><item>C</item></list>"
    result = Everyday::XmlToJsonCalculator.new(text: xml).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal %w[A B C], parsed["list"]["item"]
  end

  test "handles mixed content with #text key" do
    xml = '<name lang="en">John</name>'
    result = Everyday::XmlToJsonCalculator.new(text: xml).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal "en", parsed["name"]["@lang"]
    assert_equal "John", parsed["name"]["#text"]
  end

  test "reports root element name" do
    xml = "<root><child>value</child></root>"
    result = Everyday::XmlToJsonCalculator.new(text: xml).call
    assert result[:valid]
    assert_equal "root", result[:root_element]
  end

  test "counts elements" do
    xml = "<root><a>1</a><b>2</b></root>"
    result = Everyday::XmlToJsonCalculator.new(text: xml).call
    assert result[:valid]
    assert_equal 3, result[:element_count]
  end

  test "counts attributes" do
    xml = '<root id="1"><child name="a" type="b">value</child></root>'
    result = Everyday::XmlToJsonCalculator.new(text: xml).call
    assert result[:valid]
    assert_equal 3, result[:attribute_count]
  end

  test "returns error for empty text" do
    result = Everyday::XmlToJsonCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for invalid XML" do
    result = Everyday::XmlToJsonCalculator.new(text: "<invalid><no-close>").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid XML") || e.include?("no root element") }
  end

  test "handles nested elements" do
    xml = "<a><b><c><d>deep</d></c></b></a>"
    result = Everyday::XmlToJsonCalculator.new(text: xml).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal "deep", parsed["a"]["b"]["c"]["d"]
  end

  test "handles empty elements" do
    xml = "<root><empty/></root>"
    result = Everyday::XmlToJsonCalculator.new(text: xml).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal "", parsed["root"]["empty"]
  end

  test "handles whitespace-only text" do
    result = Everyday::XmlToJsonCalculator.new(text: "   ").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "handles XML with multiple nested repeated elements" do
    xml = "<store><book><title>A</title></book><book><title>B</title></book></store>"
    result = Everyday::XmlToJsonCalculator.new(text: xml).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_kind_of Array, parsed["store"]["book"]
    assert_equal 2, parsed["store"]["book"].length
    assert_equal "A", parsed["store"]["book"][0]["title"]
    assert_equal "B", parsed["store"]["book"][1]["title"]
  end
end
