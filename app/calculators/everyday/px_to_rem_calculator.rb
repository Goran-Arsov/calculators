# frozen_string_literal: true

module Everyday
  class PxToRemCalculator
    attr_reader :errors

    def initialize(px_value:, base_font_size: 16)
      @px_value = px_value.to_f
      @base_font_size = base_font_size.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      rem_value = @px_value / @base_font_size
      em_value = rem_value
      pt_value = @px_value * 0.75
      percentage = (rem_value * 100.0)

      {
        valid: true,
        px_value: @px_value,
        base_font_size: @base_font_size,
        rem_value: rem_value.round(4),
        em_value: em_value.round(4),
        pt_value: pt_value.round(2),
        percentage: percentage.round(2)
      }
    end

    private

    def validate!
      @errors << "Base font size must be greater than zero" if @base_font_size <= 0
    end
  end
end
