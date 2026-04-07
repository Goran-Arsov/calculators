# frozen_string_literal: true

module Everyday
  class SvgToPngCalculator
    attr_reader :errors

    MAX_DIMENSION = 4096
    DEFAULT_SCALE = 1

    def initialize(svg:, scale: DEFAULT_SCALE)
      @svg = svg.to_s
      @scale = [ [ scale.to_f, 0.1 ].max, 10.0 ].min
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      width = extract_dimension("width")
      height = extract_dimension("height")
      viewbox = extract_viewbox

      {
        valid: true,
        svg_valid: true,
        width: width,
        height: height,
        viewbox: viewbox,
        scale: @scale,
        output_width: width ? (width * @scale).round : nil,
        output_height: height ? (height * @scale).round : nil,
        element_count: count_elements,
        has_text: @svg.include?("<text"),
        has_image: @svg.include?("<image"),
        svg_size_bytes: @svg.bytesize
      }
    end

    private

    def validate!
      @errors << "SVG content cannot be empty" if @svg.strip.empty?
      @errors << "Input does not appear to be valid SVG" unless @svg.strip.match?(/<svg[\s>]/i)
    end

    def extract_dimension(attr)
      match = @svg.match(/<svg[^>]*\b#{attr}\s*=\s*["'](\d+(?:\.\d+)?)/i)
      match ? match[1].to_f : nil
    end

    def extract_viewbox
      match = @svg.match(/<svg[^>]*viewBox\s*=\s*["']([^"']+)/i)
      match ? match[1] : nil
    end

    def count_elements
      @svg.scan(/<[a-zA-Z]/).length
    end
  end
end
