# frozen_string_literal: true

module Math
  class PercentageCalculator
    attr_reader :errors

    def initialize(value:, percentage:, mode: "of")
      @value = value.to_f
      @percentage = percentage.to_f
      @mode = mode.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = case @mode
      when "of"
                 # What is X% of Y?
                 @value * @percentage / 100.0
      when "is_what_percent"
                 # X is what % of Y?
                 (@value / @percentage) * 100.0
      when "change"
                 # Percentage change from X to Y
                 ((@percentage - @value) / @value.abs) * 100.0
      end

      {
        valid: true,
        result: result.round(4),
        mode: @mode
      }
    end

    private

    def validate!
      @errors << "Invalid mode" unless %w[of is_what_percent change].include?(@mode)
      @errors << "Value cannot be zero for percentage change" if @mode == "change" && @value.zero?
      @errors << "Second value cannot be zero for 'is what percent'" if @mode == "is_what_percent" && @percentage.zero?
    end
  end
end
