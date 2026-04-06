# frozen_string_literal: true

require "rexml/document"
require "json"

module Everyday
  class XmlToJsonCalculator
    attr_reader :errors

    def initialize(text:)
      @text = text.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      begin
        doc = REXML::Document.new(@text)
      rescue REXML::ParseException => e
        @errors << "Invalid XML: #{e.message.lines.first.strip}"
        return { valid: false, errors: @errors }
      end

      if doc.root.nil?
        @errors << "XML document has no root element"
        return { valid: false, errors: @errors }
      end

      hash = element_to_hash(doc.root)
      result = { doc.root.name => hash }
      json_output = JSON.pretty_generate(result)

      {
        valid: true,
        output: json_output,
        root_element: doc.root.name,
        element_count: count_elements(doc.root),
        attribute_count: count_attributes(doc.root)
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end

    def element_to_hash(element)
      result = {}

      # Add attributes with @ prefix
      element.attributes.each do |name, value|
        result["@#{name}"] = value
      end

      # Group child elements by name to detect arrays
      children_by_name = {}
      element.each_element do |child|
        children_by_name[child.name] ||= []
        children_by_name[child.name] << child
      end

      # Process child elements
      children_by_name.each do |name, children|
        if children.length > 1
          # Repeated elements become an array
          result[name] = children.map { |child| element_to_hash(child) }
        else
          result[name] = element_to_hash(children.first)
        end
      end

      # Handle text content
      text = element.texts.map(&:value).join.strip
      if text.length > 0
        if result.empty?
          return text
        else
          result["#text"] = text
        end
      end

      # If element has no attributes, no children, and no text, return empty string
      result.empty? ? "" : result
    end

    def count_elements(element)
      count = 1
      element.each_element { |child| count += count_elements(child) }
      count
    end

    def count_attributes(element)
      count = element.attributes.size
      element.each_element { |child| count += count_attributes(child) }
      count
    end
  end
end
