# frozen_string_literal: true

module Everyday
  class CookingConverter
    attr_reader :errors

    CONVERSIONS = {
      "cups_to_ml"   => { from: "cups",  to: "ml",   factor: 236.588 },
      "ml_to_cups"   => { from: "ml",    to: "cups",  factor: 1.0 / 236.588 },
      "tbsp_to_ml"   => { from: "tbsp",  to: "ml",   factor: 14.787 },
      "tsp_to_ml"    => { from: "tsp",   to: "ml",   factor: 4.929 },
      "oz_to_g"      => { from: "oz",    to: "g",    factor: 28.3495 },
      "g_to_oz"      => { from: "g",     to: "oz",   factor: 1.0 / 28.3495 },
      "cups_to_tbsp" => { from: "cups",  to: "tbsp", factor: 16 },
      "tbsp_to_tsp"  => { from: "tbsp",  to: "tsp",  factor: 3 },
      "lb_to_kg"     => { from: "lb",    to: "kg",   factor: 0.453592 },
      "kg_to_lb"     => { from: "kg",    to: "lb",   factor: 2.20462 }
    }.freeze

    def initialize(conversion:, value:)
      @conversion = conversion.to_s
      @value = value.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      conv = CONVERSIONS[@conversion]
      result = @value * conv[:factor]

      {
        from_unit: conv[:from],
        to_unit: conv[:to],
        result: result.round(4)
      }
    end

    private

    def validate!
      @errors << "Value must be greater than zero" unless @value.positive?
      @errors << "Unknown conversion: #{@conversion}. Valid: #{CONVERSIONS.keys.join(', ')}" unless CONVERSIONS.key?(@conversion)
    end
  end
end
