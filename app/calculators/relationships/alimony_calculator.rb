# frozen_string_literal: true

module Relationships
  class AlimonyCalculator
    attr_reader :errors

    # Common "American Academy of Matrimonial Lawyers" formula approximation
    INCOME_FACTOR = 0.30
    RECIPIENT_FACTOR = 0.20
    CAP_RATIO = 0.40

    def initialize(payor_income:, recipient_income:, years_married:)
      @payor_income = payor_income.to_f
      @recipient_income = recipient_income.to_f
      @years_married = years_married.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      annual_amount = (@payor_income * INCOME_FACTOR) - (@recipient_income * RECIPIENT_FACTOR)
      cap = (@payor_income + @recipient_income) * CAP_RATIO - @recipient_income
      annual_amount = [ annual_amount, cap ].min
      annual_amount = [ annual_amount, 0 ].max

      monthly_amount = annual_amount / 12.0
      duration_years = suggested_duration

      {
        valid: true,
        annual_amount: annual_amount.round(2),
        monthly_amount: monthly_amount.round(2),
        duration_years: duration_years,
        total_amount: (annual_amount * duration_years).round(2)
      }
    end

    private

    def validate!
      @errors << "Payor income must be greater than zero" unless @payor_income.positive?
      @errors << "Recipient income cannot be negative" if @recipient_income.negative?
      @errors << "Years married must be greater than zero" unless @years_married.positive?
      @errors << "Payor income must exceed recipient income" if @payor_income <= @recipient_income && @errors.empty?
    end

    def suggested_duration
      case @years_married
      when 0..5 then (@years_married * 0.25).round(1)
      when 5..10 then (@years_married * 0.40).round(1)
      when 10..20 then (@years_married * 0.60).round(1)
      else (@years_married * 0.80).round(1)
      end
    end
  end
end
