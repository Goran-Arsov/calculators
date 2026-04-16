# frozen_string_literal: true

module Math
  class AspectRatioCalculator
    attr_reader :errors

    def initialize(width: nil, height: nil)
      @width = width.present? ? width.to_f : nil
      @height = height.present? ? height.to_f : nil
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      gcd = euclidean_gcd(@width.to_i, @height.to_i)
      ratio_width = @width.to_i / gcd
      ratio_height = @height.to_i / gcd
      decimal_ratio = (@width / @height).round(4)

      {
        valid: true,
        width: @width.round(4),
        height: @height.round(4),
        ratio_width: ratio_width,
        ratio_height: ratio_height,
        decimal_ratio: decimal_ratio
      }
    end

    private

    def euclidean_gcd(x, y)
      x = x.abs
      y = y.abs
      while y != 0
        x, y = y, x % y
      end
      x
    end

    def validate!
      @errors << "Width is required" if @width.nil?
      @errors << "Height is required" if @height.nil?
      @errors << "Width must be positive" if @width && @width <= 0
      @errors << "Height must be positive" if @height && @height <= 0
    end
  end
end
