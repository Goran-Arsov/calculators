# frozen_string_literal: true

module Everyday
  class CssFlexboxCalculator
    attr_reader :errors

    VALID_DIRECTIONS = %w[row column row-reverse column-reverse].freeze
    VALID_JUSTIFY = %w[flex-start center flex-end space-between space-around space-evenly].freeze
    VALID_ALIGN = %w[stretch flex-start center flex-end baseline].freeze
    VALID_WRAP = %w[nowrap wrap wrap-reverse].freeze

    def initialize(direction:, justify_content:, align_items:, flex_wrap:, gap:)
      @direction = direction.to_s.strip
      @justify_content = justify_content.to_s.strip
      @align_items = align_items.to_s.strip
      @flex_wrap = flex_wrap.to_s.strip
      @gap = gap.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      css_string = build_css
      {
        valid: true,
        css_string: css_string,
        direction: @direction,
        justify_content: @justify_content,
        align_items: @align_items,
        flex_wrap: @flex_wrap,
        gap: @gap
      }
    end

    private

    def validate!
      unless VALID_DIRECTIONS.include?(@direction)
        @errors << "Invalid flex-direction: #{@direction}"
      end
      unless VALID_JUSTIFY.include?(@justify_content)
        @errors << "Invalid justify-content: #{@justify_content}"
      end
      unless VALID_ALIGN.include?(@align_items)
        @errors << "Invalid align-items: #{@align_items}"
      end
      unless VALID_WRAP.include?(@flex_wrap)
        @errors << "Invalid flex-wrap: #{@flex_wrap}"
      end
      gap_value = @gap.to_f
      @errors << "Gap cannot be negative" if gap_value < 0
    end

    def build_css
      lines = []
      lines << "display: flex;"
      lines << "flex-direction: #{@direction};"
      lines << "justify-content: #{@justify_content};"
      lines << "align-items: #{@align_items};"
      lines << "flex-wrap: #{@flex_wrap};"
      lines << "gap: #{@gap}px;" if @gap.to_f > 0
      lines.join("\n")
    end
  end
end
