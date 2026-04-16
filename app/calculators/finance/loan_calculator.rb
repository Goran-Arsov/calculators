# frozen_string_literal: true

module Finance
  class LoanCalculator
    include Finance::LoanMath

    attr_reader :errors

    def initialize(amount:, annual_rate:, years:)
      @amount = amount.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @years = years.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = calculate_amortization(@amount, @annual_rate, @years)
      result.merge(valid: true)
    end

    private

    def validate!
      @errors << "Loan amount must be positive" unless @amount > 0
      @errors << "Loan term must be positive" unless @years > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
    end
  end
end
