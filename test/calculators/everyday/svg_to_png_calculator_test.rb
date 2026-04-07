require "test_helper"

class Everyday::SvgToPngCalculatorTest < ActiveSupport::TestCase
  test "analyzes valid SVG with dimensions" do
    svg = '<svg width="100" height="200" xmlns="http://www.w3.org/2000/svg"><rect width="100" height="200"/></svg>'
    result = Everyday::SvgToPngCalculator.new(svg: svg).call
    assert result[:valid]
    assert_equal 100.0, result[:width]
    assert_equal 200.0, result[:height]
  end

  test "calculates output dimensions with scale" do
    svg = '<svg width="100" height="200" xmlns="http://www.w3.org/2000/svg"><rect/></svg>'
    result = Everyday::SvgToPngCalculator.new(svg: svg, scale: 2).call
    assert result[:valid]
    assert_equal 200, result[:output_width]
    assert_equal 400, result[:output_height]
  end

  test "extracts viewBox" do
    svg = '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><circle/></svg>'
    result = Everyday::SvgToPngCalculator.new(svg: svg).call
    assert result[:valid]
    assert_equal "0 0 100 100", result[:viewbox]
  end

  test "counts SVG elements" do
    svg = '<svg xmlns="http://www.w3.org/2000/svg"><rect/><circle/><text>Hi</text></svg>'
    result = Everyday::SvgToPngCalculator.new(svg: svg).call
    assert result[:valid]
    assert result[:element_count] >= 4
  end

  test "detects text elements" do
    svg = '<svg xmlns="http://www.w3.org/2000/svg"><text>Hello</text></svg>'
    result = Everyday::SvgToPngCalculator.new(svg: svg).call
    assert result[:valid]
    assert result[:has_text]
  end

  test "detects image elements" do
    svg = '<svg xmlns="http://www.w3.org/2000/svg"><image href="test.png"/></svg>'
    result = Everyday::SvgToPngCalculator.new(svg: svg).call
    assert result[:valid]
    assert result[:has_image]
  end

  test "reports SVG size in bytes" do
    svg = '<svg xmlns="http://www.w3.org/2000/svg"><rect/></svg>'
    result = Everyday::SvgToPngCalculator.new(svg: svg).call
    assert result[:valid]
    assert_equal svg.bytesize, result[:svg_size_bytes]
  end

  test "clamps scale to valid range" do
    svg = '<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg"><rect/></svg>'
    result = Everyday::SvgToPngCalculator.new(svg: svg, scale: 50).call
    assert result[:valid]
    assert_equal 10.0, result[:scale]
  end

  test "returns error for empty SVG" do
    result = Everyday::SvgToPngCalculator.new(svg: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "SVG content cannot be empty"
  end

  test "returns error for non-SVG input" do
    result = Everyday::SvgToPngCalculator.new(svg: "<div>Not SVG</div>").call
    assert_not result[:valid]
    assert_includes result[:errors], "Input does not appear to be valid SVG"
  end
end
