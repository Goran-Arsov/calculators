# frozen_string_literal: true

module Everyday
  class SchemaGeneratorCalculator
    attr_reader :errors

    VALID_TYPES = %w[article product faq local_business event recipe].freeze

    REQUIRED_FIELDS = {
      "article" => %w[headline author datePublished],
      "product" => %w[name description price currency],
      "faq" => %w[questions],
      "local_business" => %w[name address phone],
      "event" => %w[name startDate location],
      "recipe" => %w[name ingredients instructions]
    }.freeze

    def initialize(type:, fields:)
      @type = type.to_s.strip
      @fields = fields.is_a?(Hash) ? fields : {}
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      json_ld = build_json_ld

      {
        valid: true,
        json_ld: JSON.pretty_generate(json_ld),
        type: @type
      }
    end

    private

    def build_json_ld
      case @type
      when "article"    then build_article
      when "product"    then build_product
      when "faq"        then build_faq
      when "local_business" then build_local_business
      when "event"      then build_event
      when "recipe"     then build_recipe
      end
    end

    def build_article
      schema = {
        "@context" => "https://schema.org",
        "@type" => "Article",
        "headline" => @fields["headline"].to_s,
        "author" => {
          "@type" => "Person",
          "name" => @fields["author"].to_s
        },
        "datePublished" => @fields["datePublished"].to_s
      }
      schema["image"] = @fields["image"].to_s if @fields["image"].present?
      if @fields["publisher"].present?
        schema["publisher"] = {
          "@type" => "Organization",
          "name" => @fields["publisher"].to_s
        }
      end
      schema
    end

    def build_product
      schema = {
        "@context" => "https://schema.org",
        "@type" => "Product",
        "name" => @fields["name"].to_s,
        "description" => @fields["description"].to_s
      }
      schema["image"] = @fields["image"].to_s if @fields["image"].present?
      schema["brand"] = { "@type" => "Brand", "name" => @fields["brand"].to_s } if @fields["brand"].present?
      schema["offers"] = {
        "@type" => "Offer",
        "price" => @fields["price"].to_s,
        "priceCurrency" => @fields["currency"].to_s.upcase.presence || "USD",
        "availability" => @fields["availability"].to_s.presence || "https://schema.org/InStock"
      }
      schema
    end

    def build_faq
      questions = @fields["questions"]
      questions = [] unless questions.is_a?(Array)

      entries = questions.select { |q| q.is_a?(Hash) && q["question"].present? && q["answer"].present? }

      {
        "@context" => "https://schema.org",
        "@type" => "FAQPage",
        "mainEntity" => entries.map do |q|
          {
            "@type" => "Question",
            "name" => q["question"].to_s,
            "acceptedAnswer" => {
              "@type" => "Answer",
              "text" => q["answer"].to_s
            }
          }
        end
      }
    end

    def build_local_business
      schema = {
        "@context" => "https://schema.org",
        "@type" => "LocalBusiness",
        "name" => @fields["name"].to_s,
        "address" => @fields["address"].to_s,
        "telephone" => @fields["phone"].to_s
      }
      schema["url"] = @fields["url"].to_s if @fields["url"].present?
      schema["openingHours"] = @fields["openingHours"].to_s if @fields["openingHours"].present?
      schema
    end

    def build_event
      schema = {
        "@context" => "https://schema.org",
        "@type" => "Event",
        "name" => @fields["name"].to_s,
        "startDate" => @fields["startDate"].to_s,
        "location" => {
          "@type" => "Place",
          "name" => @fields["location"].to_s
        }
      }
      schema["endDate"] = @fields["endDate"].to_s if @fields["endDate"].present?
      schema["description"] = @fields["description"].to_s if @fields["description"].present?
      schema
    end

    def build_recipe
      ingredients = @fields["ingredients"]
      ingredients = ingredients.is_a?(Array) ? ingredients : []

      instructions = @fields["instructions"]
      instructions = instructions.is_a?(Array) ? instructions : []

      schema = {
        "@context" => "https://schema.org",
        "@type" => "Recipe",
        "name" => @fields["name"].to_s,
        "recipeIngredient" => ingredients.map(&:to_s),
        "recipeInstructions" => instructions.map.with_index(1) do |step, i|
          {
            "@type" => "HowToStep",
            "position" => i,
            "text" => step.to_s
          }
        end
      }
      schema["prepTime"] = @fields["prepTime"].to_s if @fields["prepTime"].present?
      schema["cookTime"] = @fields["cookTime"].to_s if @fields["cookTime"].present?
      schema
    end

    def validate!
      @errors << "Type is required" if @type.blank?
      @errors << "Type must be one of: #{VALID_TYPES.join(', ')}" if @type.present? && !VALID_TYPES.include?(@type)
      return if @errors.any?

      required = REQUIRED_FIELDS[@type] || []
      required.each do |field|
        value = @fields[field]
        if field == "questions"
          @errors << "At least one question/answer pair is required" unless value.is_a?(Array) && value.any? { |q| q.is_a?(Hash) && q["question"].present? && q["answer"].present? }
        elsif field == "ingredients" || field == "instructions"
          @errors << "#{field.capitalize} must be a non-empty list" unless value.is_a?(Array) && value.any?(&:present?)
        else
          @errors << "#{field} is required" if value.blank?
        end
      end
    end
  end
end
