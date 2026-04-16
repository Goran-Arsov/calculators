# frozen_string_literal: true

module Math
  class ProbabilityCalculator
    attr_reader :errors

    def initialize(favorable:, total:)
      @favorable = favorable.to_f
      @total = total.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      probability = @favorable / @total
      complementary = 1.0 - probability
      odds_for = @favorable / (@total - @favorable)
      odds_against = (@total - @favorable) / @favorable
      percentage = probability * 100.0

      {
        valid: true,
        favorable: @favorable.round(4),
        total: @total.round(4),
        probability: probability.round(8),
        percentage: percentage.round(4),
        complementary: complementary.round(8),
        complementary_percentage: (complementary * 100.0).round(4),
        odds_for: odds_for.round(4),
        odds_against: odds_against.round(4),
        odds_ratio: "#{@favorable.round(0).to_i}:#{(@total - @favorable).round(0).to_i}"
      }
    end

    private

    def validate!
      @errors << "Total outcomes must be greater than zero" if @total <= 0
      @errors << "Favorable outcomes cannot be negative" if @favorable < 0
      @errors << "Favorable outcomes cannot exceed total outcomes" if @favorable > @total
      @errors << "Favorable outcomes must be greater than zero for odds calculation" if @favorable.zero? && @total > 0
    end
  end
end
