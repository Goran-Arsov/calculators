# frozen_string_literal: true

module Math
  class CircumferenceCalculator
    attr_reader :errors

    def initialize(radius: nil, diameter: nil)
      @radius = radius&.to_f
      @diameter = diameter&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      r = @radius || @diameter / 2.0
      d = @diameter || @radius * 2.0

      circumference = 2 * ::Math::PI * r
      area = ::Math::PI * r**2

      {
        valid: true,
        circumference: circumference.round(4),
        area: area.round(4),
        radius: r.round(4),
        diameter: d.round(4)
      }
    end

    private

    def validate!
      if @radius.nil? && @diameter.nil?
        @errors << "Provide either radius or diameter"
      elsif @radius && @radius <= 0
        @errors << "Radius must be positive"
      elsif @diameter && @diameter <= 0
        @errors << "Diameter must be positive"
      end
    end
  end
end
