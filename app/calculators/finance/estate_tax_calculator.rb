# frozen_string_literal: true

module Finance
  class EstateTaxCalculator
    attr_reader :errors

    # 2024 federal estate tax exemption
    SINGLE_EXEMPTION = 13_610_000.0
    MARRIED_EXEMPTION = 27_220_000.0 # Portability: surviving spouse can use deceased spouse's unused exemption

    # Federal estate tax brackets (2024)
    ESTATE_TAX_BRACKETS = [
      { min: 0,         max: 10_000,          rate: 0.18 },
      { min: 10_001,    max: 20_000,          rate: 0.20 },
      { min: 20_001,    max: 40_000,          rate: 0.22 },
      { min: 40_001,    max: 60_000,          rate: 0.24 },
      { min: 60_001,    max: 80_000,          rate: 0.26 },
      { min: 80_001,    max: 100_000,         rate: 0.28 },
      { min: 100_001,   max: 150_000,         rate: 0.30 },
      { min: 150_001,   max: 250_000,         rate: 0.32 },
      { min: 250_001,   max: 500_000,         rate: 0.34 },
      { min: 500_001,   max: 750_000,         rate: 0.37 },
      { min: 750_001,   max: 1_000_000,       rate: 0.39 },
      { min: 1_000_001, max: Float::INFINITY, rate: 0.40 }
    ].freeze

    VALID_STATUSES = %w[single married].freeze

    def initialize(estate_value:, filing_status: "single", deductions: 0)
      @estate_value = estate_value.to_f
      @filing_status = filing_status.to_s.downcase.strip
      @deductions = deductions.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      exemption = @filing_status == "married" ? MARRIED_EXEMPTION : SINGLE_EXEMPTION
      taxable_estate = [ @estate_value - @deductions - exemption, 0 ].max

      estate_tax = calculate_estate_tax(taxable_estate)
      effective_rate = @estate_value > 0 ? (estate_tax / @estate_value * 100) : 0.0
      net_to_heirs = @estate_value - estate_tax - @deductions

      {
        valid: true,
        estate_value: @estate_value.round(2),
        exemption: exemption.round(2),
        deductions: @deductions.round(2),
        taxable_estate: taxable_estate.round(2),
        estate_tax: estate_tax.round(2),
        effective_rate: effective_rate.round(2),
        net_to_heirs: net_to_heirs.round(2),
        filing_status: @filing_status
      }
    end

    private

    def validate!
      @errors << "Estate value must be positive" unless @estate_value > 0
      @errors << "Invalid filing status" unless VALID_STATUSES.include?(@filing_status)
      @errors << "Deductions cannot be negative" if @deductions < 0
      @errors << "Deductions cannot exceed estate value" if @deductions > @estate_value && @estate_value > 0
    end

    def calculate_estate_tax(taxable_amount)
      return 0.0 if taxable_amount <= 0

      remaining = taxable_amount
      total_tax = 0.0

      ESTATE_TAX_BRACKETS.each do |bracket|
        break if remaining <= 0

        bracket_width = if bracket[:max] == Float::INFINITY
                          remaining
        elsif bracket[:min] == 0
                          bracket[:max] + 1
        else
                          bracket[:max] - bracket[:min] + 1
        end

        taxable_in_bracket = [ remaining, bracket_width ].min
        total_tax += taxable_in_bracket * bracket[:rate]
        remaining -= taxable_in_bracket
      end

      total_tax
    end
  end
end
