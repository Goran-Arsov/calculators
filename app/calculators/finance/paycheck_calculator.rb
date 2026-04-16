# frozen_string_literal: true

module Finance
  class PaycheckCalculator
    attr_reader :errors

    # 2024 federal tax brackets for single filer
    FEDERAL_BRACKETS = [
      { min: 0,       max: 11_600,          rate: 0.10 },
      { min: 11_601,  max: 47_150,          rate: 0.12 },
      { min: 47_151,  max: 100_525,         rate: 0.22 },
      { min: 100_526, max: 191_950,         rate: 0.24 },
      { min: 191_951, max: 243_725,         rate: 0.32 },
      { min: 243_726, max: 609_350,         rate: 0.35 },
      { min: 609_351, max: Float::INFINITY, rate: 0.37 }
    ].freeze

    # Flat state tax rates (simplified)
    STATE_TAX_RATES = {
      "none"       => 0.0,
      "low"        => 0.03,
      "medium"     => 0.05,
      "high"       => 0.07,
      "very_high"  => 0.10
    }.freeze

    # FICA rates for 2024
    SOCIAL_SECURITY_RATE = 0.062
    SOCIAL_SECURITY_WAGE_BASE = 168_600.0
    MEDICARE_RATE = 0.0145
    MEDICARE_SURTAX_RATE = 0.009
    MEDICARE_SURTAX_THRESHOLD = 200_000.0

    VALID_PAY_FREQUENCIES = %w[weekly biweekly semimonthly monthly].freeze
    PAY_PERIODS = {
      "weekly"      => 52,
      "biweekly"    => 26,
      "semimonthly" => 24,
      "monthly"     => 12
    }.freeze

    def initialize(annual_salary:, state_tax_level: "medium", pay_frequency: "biweekly", pre_tax_deductions: 0)
      @annual_salary = annual_salary.to_f
      @state_tax_level = state_tax_level.to_s.downcase.strip
      @pay_frequency = pay_frequency.to_s.downcase.strip
      @pre_tax_deductions = pre_tax_deductions.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      taxable_income = [ @annual_salary - @pre_tax_deductions, 0 ].max
      periods = PAY_PERIODS[@pay_frequency]

      federal_tax = calculate_federal_tax(taxable_income)
      state_tax = taxable_income * STATE_TAX_RATES[@state_tax_level]
      social_security = [ taxable_income, SOCIAL_SECURITY_WAGE_BASE ].min * SOCIAL_SECURITY_RATE
      medicare = taxable_income * MEDICARE_RATE
      medicare += [ taxable_income - MEDICARE_SURTAX_THRESHOLD, 0 ].max * MEDICARE_SURTAX_RATE
      fica = social_security + medicare

      total_deductions = federal_tax + state_tax + fica + @pre_tax_deductions
      annual_net = @annual_salary - total_deductions
      per_paycheck_gross = @annual_salary / periods
      per_paycheck_net = annual_net / periods

      {
        valid: true,
        annual_gross: @annual_salary.round(2),
        annual_net: annual_net.round(2),
        per_paycheck_gross: per_paycheck_gross.round(2),
        per_paycheck_net: per_paycheck_net.round(2),
        federal_tax: federal_tax.round(2),
        state_tax: state_tax.round(2),
        social_security: social_security.round(2),
        medicare: medicare.round(2),
        fica: fica.round(2),
        pre_tax_deductions: @pre_tax_deductions.round(2),
        total_deductions: total_deductions.round(2),
        effective_tax_rate: (taxable_income > 0 ? (federal_tax + state_tax) / taxable_income * 100 : 0.0).round(2),
        pay_periods: periods
      }
    end

    private

    def validate!
      @errors << "Annual salary must be positive" unless @annual_salary > 0
      @errors << "Pre-tax deductions cannot be negative" if @pre_tax_deductions < 0
      @errors << "Pre-tax deductions cannot exceed salary" if @pre_tax_deductions > @annual_salary && @annual_salary > 0
      @errors << "Invalid state tax level" unless STATE_TAX_RATES.key?(@state_tax_level)
      @errors << "Invalid pay frequency" unless VALID_PAY_FREQUENCIES.include?(@pay_frequency)
    end

    def calculate_federal_tax(taxable_income)
      remaining = taxable_income
      total_tax = 0.0

      FEDERAL_BRACKETS.each do |bracket|
        break if remaining <= 0

        bracket_width = if bracket[:min] == 0
                          bracket[:max] + 1
        else
                          bracket[:max] == Float::INFINITY ? remaining : bracket[:max] - bracket[:min] + 1
        end

        taxable_in_bracket = [ remaining, bracket_width ].min
        total_tax += taxable_in_bracket * bracket[:rate]
        remaining -= taxable_in_bracket
      end

      total_tax
    end
  end
end
