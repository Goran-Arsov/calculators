require "test_helper"

class Everyday::SchemaGeneratorCalculatorTest < ActiveSupport::TestCase
  # --- Article ---

  test "generates valid article schema" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "article",
      fields: { "headline" => "Test Article", "author" => "Jane Doe", "datePublished" => "2025-01-15" }
    ).call
    assert result[:valid]
    json = JSON.parse(result[:json_ld])
    assert_equal "Article", json["@type"]
    assert_equal "https://schema.org", json["@context"]
    assert_equal "Test Article", json["headline"]
    assert_equal "Jane Doe", json["author"]["name"]
    assert_equal "2025-01-15", json["datePublished"]
    assert_equal "article", result[:type]
  end

  test "article schema includes optional image and publisher" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "article",
      fields: { "headline" => "Test", "author" => "John", "datePublished" => "2025-01-01", "image" => "https://example.com/img.jpg", "publisher" => "Acme Corp" }
    ).call
    json = JSON.parse(result[:json_ld])
    assert_equal "https://example.com/img.jpg", json["image"]
    assert_equal "Acme Corp", json["publisher"]["name"]
  end

  test "article error when headline missing" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "article",
      fields: { "author" => "Jane", "datePublished" => "2025-01-01" }
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "headline is required"
  end

  # --- Product ---

  test "generates valid product schema" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "product",
      fields: { "name" => "Widget", "description" => "A fine widget", "price" => "29.99", "currency" => "USD" }
    ).call
    assert result[:valid]
    json = JSON.parse(result[:json_ld])
    assert_equal "Product", json["@type"]
    assert_equal "Widget", json["name"]
    assert_equal "29.99", json["offers"]["price"]
    assert_equal "USD", json["offers"]["priceCurrency"]
  end

  test "product error when price missing" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "product",
      fields: { "name" => "Widget", "description" => "Desc", "currency" => "USD" }
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "price is required"
  end

  # --- FAQ ---

  test "generates valid faq schema" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "faq",
      fields: { "questions" => [ { "question" => "What?", "answer" => "This." }, { "question" => "Why?", "answer" => "Because." } ] }
    ).call
    assert result[:valid]
    json = JSON.parse(result[:json_ld])
    assert_equal "FAQPage", json["@type"]
    assert_equal 2, json["mainEntity"].size
    assert_equal "What?", json["mainEntity"][0]["name"]
    assert_equal "This.", json["mainEntity"][0]["acceptedAnswer"]["text"]
  end

  test "faq error when no valid questions provided" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "faq",
      fields: { "questions" => [] }
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("question/answer pair") }
  end

  # --- LocalBusiness ---

  test "generates valid local business schema" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "local_business",
      fields: { "name" => "Joe's Shop", "address" => "123 Main St", "phone" => "+1-555-0100" }
    ).call
    assert result[:valid]
    json = JSON.parse(result[:json_ld])
    assert_equal "LocalBusiness", json["@type"]
    assert_equal "Joe's Shop", json["name"]
    assert_equal "+1-555-0100", json["telephone"]
  end

  test "local business error when name missing" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "local_business",
      fields: { "address" => "123 Main St", "phone" => "+1-555-0100" }
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "name is required"
  end

  # --- Event ---

  test "generates valid event schema" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "event",
      fields: { "name" => "Conference", "startDate" => "2025-06-01T09:00", "location" => "Convention Center" }
    ).call
    assert result[:valid]
    json = JSON.parse(result[:json_ld])
    assert_equal "Event", json["@type"]
    assert_equal "Conference", json["name"]
    assert_equal "Convention Center", json["location"]["name"]
  end

  # --- Recipe ---

  test "generates valid recipe schema" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "recipe",
      fields: {
        "name" => "Pancakes",
        "prepTime" => "PT10M",
        "cookTime" => "PT15M",
        "ingredients" => [ "2 cups flour", "1 egg", "1 cup milk" ],
        "instructions" => [ "Mix dry ingredients", "Add wet ingredients", "Cook on griddle" ]
      }
    ).call
    assert result[:valid]
    json = JSON.parse(result[:json_ld])
    assert_equal "Recipe", json["@type"]
    assert_equal "Pancakes", json["name"]
    assert_equal 3, json["recipeIngredient"].size
    assert_equal 3, json["recipeInstructions"].size
    assert_equal "HowToStep", json["recipeInstructions"][0]["@type"]
    assert_equal 1, json["recipeInstructions"][0]["position"]
  end

  test "recipe error when ingredients empty" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "recipe",
      fields: { "name" => "Pancakes", "ingredients" => [], "instructions" => [ "Cook" ] }
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Ingredients") }
  end

  # --- General validation ---

  test "error when type is blank" do
    result = Everyday::SchemaGeneratorCalculator.new(type: "", fields: {}).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Type is required"
  end

  test "error when type is invalid" do
    result = Everyday::SchemaGeneratorCalculator.new(type: "unknown", fields: {}).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("must be one of") }
  end

  test "json_ld string is valid JSON" do
    result = Everyday::SchemaGeneratorCalculator.new(
      type: "article",
      fields: { "headline" => "Test", "author" => "Me", "datePublished" => "2025-01-01" }
    ).call
    assert_nothing_raised { JSON.parse(result[:json_ld]) }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::SchemaGeneratorCalculator.new(type: "article", fields: {})
    assert_equal [], calc.errors
  end
end
