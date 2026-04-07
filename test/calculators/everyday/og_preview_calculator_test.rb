require "test_helper"

class Everyday::OgPreviewCalculatorTest < ActiveSupport::TestCase
  test "analyzes complete OG tags" do
    tags = {
      "og:title" => "My Page",
      "og:description" => "A great page",
      "og:url" => "https://example.com",
      "og:type" => "website",
      "og:image" => "https://example.com/image.png"
    }
    result = Everyday::OgPreviewCalculator.new(tags: tags).call
    assert result[:valid]
    assert result[:score] > 0
    assert result[:has_image]
    assert_equal 7, result[:title_length]
  end

  test "identifies missing required tags" do
    tags = { "og:title" => "My Page" }
    result = Everyday::OgPreviewCalculator.new(tags: tags).call
    assert result[:valid]
    assert_includes result[:missing_required], "og:description"
    assert_includes result[:missing_required], "og:url"
  end

  test "identifies missing recommended tags" do
    tags = { "og:title" => "Page", "og:description" => "Desc", "og:url" => "https://x.com", "og:type" => "website" }
    result = Everyday::OgPreviewCalculator.new(tags: tags).call
    assert result[:valid]
    assert_includes result[:missing_recommended], "og:image"
    assert_includes result[:missing_recommended], "twitter:card"
  end

  test "generates meta HTML" do
    tags = { "og:title" => "Test", "twitter:card" => "summary" }
    result = Everyday::OgPreviewCalculator.new(tags: tags).call
    assert result[:valid]
    assert_includes result[:meta_html], 'property="og:title"'
    assert_includes result[:meta_html], 'name="twitter:card"'
  end

  test "calculates score" do
    all_tags = {
      "og:title" => "T", "og:description" => "D", "og:url" => "U", "og:type" => "website",
      "og:image" => "I", "og:site_name" => "S", "og:locale" => "L",
      "twitter:card" => "C", "twitter:title" => "T", "twitter:description" => "D", "twitter:image" => "I"
    }
    result = Everyday::OgPreviewCalculator.new(tags: all_tags).call
    assert result[:valid]
    assert_equal 100, result[:score]
  end

  test "returns error when all tags empty" do
    result = Everyday::OgPreviewCalculator.new(tags: { "og:title" => "", "og:description" => "" }).call
    assert_not result[:valid]
    assert_includes result[:errors], "At least one Open Graph tag must be provided"
  end

  test "escapes HTML in meta output" do
    tags = { "og:title" => 'Test <script>alert("xss")</script>' }
    result = Everyday::OgPreviewCalculator.new(tags: tags).call
    assert result[:valid]
    assert_not_includes result[:meta_html], "<script>"
    assert_includes result[:meta_html], "&lt;script&gt;"
  end

  test "reports description length" do
    tags = { "og:title" => "T", "og:description" => "A longer description here" }
    result = Everyday::OgPreviewCalculator.new(tags: tags).call
    assert result[:valid]
    assert_equal 25, result[:description_length]
  end
end
