# frozen_string_literal: true

module Math
  class SampleSizeCalculator
    attr_reader :errors

    Z_SCORES = {
      90 => 1.645,
      95 => 1.96,
      99 => 2.576
    }.freeze

    def initialize(confidence_level:, margin_of_error:, population_proportion: 0.5)
      @confidence_level = confidence_level.to_i
      @margin_of_error = margin_of_error.to_f
      @population_proportion = population_proportion.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      z = Z_SCORES[@confidence_level]
      p = @population_proportion
      e = @margin_of_error / 100.0

      sample_size = (z**2 * p * (1 - p)) / (e**2)

      {
        valid: true,
        sample_size: sample_size.ceil,
        z_score: z,
        confidence_level: @confidence_level,
        margin_of_error: @margin_of_error,
        population_proportion: @population_proportion.round(4)
      }
    end

    private

    def validate!
      unless Z_SCORES.key?(@confidence_level)
        @errors << "Confidence level must be 90, 95, or 99"
      end
      @errors << "Margin of error must be greater than 0" if @margin_of_error <= 0
      @errors << "Margin of error must be less than or equal to 100" if @margin_of_error > 100
      if @population_proportion < 0 || @population_proportion > 1
        @errors << "Population proportion must be between 0 and 1"
      end
    end
  end
end
