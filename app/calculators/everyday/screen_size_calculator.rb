# frozen_string_literal: true

module Everyday
  class ScreenSizeCalculator
    attr_reader :errors

    def initialize(diagonal:, aspect_width:, aspect_height:, resolution_h: 0, resolution_v: 0)
      @diagonal = diagonal.to_f
      @aspect_w = aspect_width.to_f
      @aspect_h = aspect_height.to_f
      @res_h = resolution_h.to_i
      @res_v = resolution_v.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # From diagonal and aspect ratio, calculate width and height
      # diagonal^2 = width^2 + height^2
      # width / height = aspect_w / aspect_h
      # width = height * (aspect_w / aspect_h)
      # diagonal^2 = height^2 * (ratio^2 + 1)
      ratio = @aspect_w / @aspect_h
      height = @diagonal / Math.sqrt(ratio**2 + 1)
      width = height * ratio

      area = width * height

      result = {
        valid: true,
        width: width.round(2),
        height: height.round(2),
        area: area.round(2),
        diagonal: @diagonal,
        aspect_ratio: "#{@aspect_w.to_i}:#{@aspect_h.to_i}"
      }

      if @res_h.positive? && @res_v.positive?
        diagonal_pixels = Math.sqrt(@res_h**2 + @res_v**2)
        ppi = diagonal_pixels / @diagonal
        result[:ppi] = ppi.round(1)
        result[:resolution] = "#{@res_h} x #{@res_v}"
        result[:total_pixels] = @res_h * @res_v
      end

      result
    end

    private

    def validate!
      @errors << "Diagonal must be greater than zero" unless @diagonal.positive?
      @errors << "Aspect width must be greater than zero" unless @aspect_w.positive?
      @errors << "Aspect height must be greater than zero" unless @aspect_h.positive?
      @errors << "Resolution width cannot be negative" if @res_h.negative?
      @errors << "Resolution height cannot be negative" if @res_v.negative?
    end
  end
end
