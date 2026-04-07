# frozen_string_literal: true

module Everyday
  class CssBoxShadowCalculator
    attr_reader :errors

    def initialize(h_offset:, v_offset:, blur:, spread:, color:, inset: false)
      @h_offset = h_offset.to_i
      @v_offset = v_offset.to_i
      @blur = blur.to_i
      @spread = spread.to_i
      @color = color.to_s.strip
      @inset = inset
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      css_value = build_css_value
      {
        valid: true,
        css_value: css_value,
        css_property: "box-shadow: #{css_value};",
        h_offset: @h_offset,
        v_offset: @v_offset,
        blur: @blur,
        spread: @spread,
        color: @color,
        inset: @inset
      }
    end

    private

    def validate!
      @errors << "Blur radius cannot be negative" if @blur < 0
      @errors << "Color cannot be empty" if @color.empty?
      unless @color.match?(/\A#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\z/)
        @errors << "Color must be a valid hex value (e.g. #000000)"
      end
    end

    def build_css_value
      parts = []
      parts << "inset" if @inset
      parts << "#{@h_offset}px"
      parts << "#{@v_offset}px"
      parts << "#{@blur}px"
      parts << "#{@spread}px"
      parts << @color
      parts.join(" ")
    end
  end
end
