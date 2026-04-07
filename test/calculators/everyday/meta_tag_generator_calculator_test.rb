require "test_helper"

class Everyday::MetaTagGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates basic meta tags with title and description" do
    result = Everyday::MetaTagGeneratorCalculator.new(
      title: "My Page Title",
      description: "A brief description of the page."
    ).call
    assert result[:valid]
    assert_includes result[:html], "<title>My Page Title</title>"
    assert_includes result[:html], '<meta name="description" content="A brief description of the page.">'
  end

  test "generates open graph tags" do
    result = Everyday::MetaTagGeneratorCalculator.new(
      title: "My Page",
      og_title: "OG Title",
      og_description: "OG Description",
      og_image: "https://example.com/image.jpg",
      og_url: "https://example.com"
    ).call
    assert result[:valid]
    assert_includes result[:html], '<meta property="og:title" content="OG Title">'
    assert_includes result[:html], '<meta property="og:description" content="OG Description">'
    assert_includes result[:html], '<meta property="og:image" content="https://example.com/image.jpg">'
    assert_includes result[:html], '<meta property="og:url" content="https://example.com">'
    assert_includes result[:html], '<meta property="og:type" content="website">'
  end

  test "generates twitter card tags" do
    result = Everyday::MetaTagGeneratorCalculator.new(
      title: "My Page",
      twitter_card: "summary"
    ).call
    assert result[:valid]
    assert_includes result[:html], '<meta name="twitter:card" content="summary">'
  end

  test "falls back to title when og_title is empty" do
    result = Everyday::MetaTagGeneratorCalculator.new(title: "Page Title").call
    assert result[:valid]
    assert_includes result[:html], '<meta property="og:title" content="Page Title">'
    assert_includes result[:html], '<meta name="twitter:title" content="Page Title">'
  end

  test "includes keywords when provided" do
    result = Everyday::MetaTagGeneratorCalculator.new(
      title: "Test", keywords: "ruby, rails, web"
    ).call
    assert result[:valid]
    assert_includes result[:html], '<meta name="keywords" content="ruby, rails, web">'
  end

  test "includes author when provided" do
    result = Everyday::MetaTagGeneratorCalculator.new(
      title: "Test", author: "John Doe"
    ).call
    assert result[:valid]
    assert_includes result[:html], '<meta name="author" content="John Doe">'
  end

  test "includes viewport tag" do
    result = Everyday::MetaTagGeneratorCalculator.new(title: "Test").call
    assert result[:valid]
    assert_includes result[:html], '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
  end

  test "includes robots tag" do
    result = Everyday::MetaTagGeneratorCalculator.new(
      title: "Test", robots: "noindex, nofollow"
    ).call
    assert result[:valid]
    assert_includes result[:html], '<meta name="robots" content="noindex, nofollow">'
  end

  test "returns title length" do
    result = Everyday::MetaTagGeneratorCalculator.new(title: "Hello World").call
    assert result[:valid]
    assert_equal 11, result[:title_length]
  end

  test "returns description length" do
    result = Everyday::MetaTagGeneratorCalculator.new(
      title: "Test", description: "Short desc"
    ).call
    assert result[:valid]
    assert_equal 10, result[:description_length]
  end

  test "title status is good for short title" do
    result = Everyday::MetaTagGeneratorCalculator.new(title: "Short").call
    assert_equal "good", result[:title_status]
  end

  test "title status is warning for 61-70 chars" do
    title = "A" * 65
    result = Everyday::MetaTagGeneratorCalculator.new(title: title).call
    assert_equal "warning", result[:title_status]
  end

  test "title status is too_long for over 70 chars" do
    title = "A" * 80
    result = Everyday::MetaTagGeneratorCalculator.new(title: title).call
    assert_equal "too_long", result[:title_status]
  end

  test "description status is good for short description" do
    result = Everyday::MetaTagGeneratorCalculator.new(
      title: "Test", description: "Short"
    ).call
    assert_equal "good", result[:description_status]
  end

  test "description status is too_long for over 180 chars" do
    desc = "A" * 200
    result = Everyday::MetaTagGeneratorCalculator.new(
      title: "Test", description: desc
    ).call
    assert_equal "too_long", result[:description_status]
  end

  test "returns error for empty title" do
    result = Everyday::MetaTagGeneratorCalculator.new(title: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Title cannot be empty"
  end

  test "escapes HTML special characters" do
    result = Everyday::MetaTagGeneratorCalculator.new(
      title: "Title with <script> & \"quotes\""
    ).call
    assert result[:valid]
    assert_includes result[:html], "&lt;script&gt;"
    assert_includes result[:html], "&amp;"
    assert_includes result[:html], "&quot;quotes&quot;"
  end
end
