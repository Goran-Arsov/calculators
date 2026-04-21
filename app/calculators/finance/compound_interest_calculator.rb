# frozen_string_literal: true

module Finance
  class CompoundInterestCalculator
    include Finance::InflationAdjustment

    attr_reader :errors

    def initialize(principal:, annual_rate:, years:, compounds_per_year: 12, annual_inflation_rate: nil)
      @principal = principal.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @years = years.to_i
      @compounds_per_year = compounds_per_year.to_i
      @annual_inflation_rate = annual_inflation_rate.nil? ? nil : annual_inflation_rate.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @annual_rate.zero?
        future_value = @principal
        total_interest = 0.0
      else
        n = @compounds_per_year
        future_value = @principal * (1 + @annual_rate / n)**(n * @years)
        total_interest = future_value - @principal
      end

      result = {
        valid: true,
        future_value: future_value.round(2),
        total_interest: total_interest.round(2),
        principal: @principal.round(2)
      }
      apply_inflation(result, years: @years, nominal_keys: [ :future_value, :total_interest ])
    end

    private

    def validate!
      @errors << "Principal must be positive" unless @principal > 0
      @errors << "Time period must be positive" unless @years > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
      @errors << "Compounding frequency must be positive" unless @compounds_per_year > 0
      @errors << inflation_rate_error if inflation_rate_error
    end
  end
end
