# frozen_string_literal: true

module Finance
  class MortgageCalculator
    include Finance::LoanMath

    attr_reader :errors

    def initialize(principal:, annual_rate:, years:)
      @principal = principal.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @years = years.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = calculate_amortization(@principal, @annual_rate, @years)
      result.merge(valid: true)
    end

    private

    def validate!
      @errors << "Principal must be positive" unless @principal > 0
      @errors << "Loan term must be positive" unless @years > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
    end
  end
end
