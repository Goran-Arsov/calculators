# frozen_string_literal: true

module Everyday
  # Converts a space-separated list of Tailwind utility classes into the
  # equivalent plain CSS declarations, returning both a per-class breakdown
  # and a combined `.element { ... }` rule.
  #
  # Conversion tables live in tailwind_to_css_calculator/mappings.rb;
  # per-class conversion logic lives in tailwind_to_css_calculator/class_converter.rb.
  class TailwindToCssCalculator
    attr_reader :errors

    def initialize(tailwind_classes:)
      @tailwind_classes = tailwind_classes.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      classes = @tailwind_classes.split(/\s+/).map(&:strip).reject(&:empty?)
      conversions = classes.map { |cls| convert(cls) }

      {
        valid: true,
        conversions: conversions,
        css_output: build_css_output(conversions),
        total_classes: classes.size,
        converted_count: conversions.count { |c| c[:converted] },
        unconverted_count: conversions.count { |c| !c[:converted] }
      }
    end

    private

    def validate!
      @errors << "Tailwind classes are required" if @tailwind_classes.empty?
    end

    def convert(cls)
      css = ClassConverter.call(cls)
      if css
        { class_name: cls, css: css, converted: true }
      else
        { class_name: cls, css: "/* #{cls}: not mapped */", converted: false }
      end
    end

    def build_css_output(conversions)
      css_lines = conversions.map { |c| c[:css] }
      ".element {\n  #{css_lines.join("\n  ")}\n}"
    end
  end
end
