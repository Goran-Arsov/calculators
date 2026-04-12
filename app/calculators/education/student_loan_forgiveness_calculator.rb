# frozen_string_literal: true

module Education
  class StudentLoanForgivenessCalculator
    attr_reader :errors

    VALID_PROGRAMS = %w[pslf idr_20 idr_25].freeze

    def initialize(loan_balance:, annual_rate:, monthly_income:, program: "pslf", payments_made: 0, filing_status: "single", family_size: 1)
      @loan_balance = loan_balance.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @monthly_income = monthly_income.to_f
      @program = program.to_s.downcase.strip
      @payments_made = payments_made.to_i
      @filing_status = filing_status.to_s.downcase.strip
      @family_size = family_size.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = case @program
      when "pslf" then calculate_pslf
      when "idr_20" then calculate_idr(20)
      when "idr_25" then calculate_idr(25)
      end

      result.merge(
        valid: true,
        loan_balance: @loan_balance.round(2),
        annual_rate: (@annual_rate * 100).round(2),
        program: @program,
        payments_made: @payments_made
      )
    end

    private

    POVERTY_GUIDELINES = {
      1 => 15_060,
      2 => 20_440,
      3 => 25_820,
      4 => 31_200,
      5 => 36_580,
      6 => 41_960,
      7 => 47_340,
      8 => 52_720
    }.freeze

    def validate!
      @errors << "Loan balance must be positive" unless @loan_balance > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
      @errors << "Monthly income must be positive" unless @monthly_income > 0
      @errors << "Invalid forgiveness program" unless VALID_PROGRAMS.include?(@program)
      @errors << "Payments made cannot be negative" if @payments_made < 0
      @errors << "Family size must be between 1 and 8" unless @family_size.between?(1, 8)
    end

    def poverty_line
      POVERTY_GUIDELINES.fetch(@family_size, 15_060).to_f
    end

    def idr_monthly_payment
      annual_income = @monthly_income * 12
      discretionary = [ annual_income - poverty_line * 1.5, 0 ].max
      (discretionary * 0.10 / 12.0)
    end

    # PSLF: forgiveness after 120 qualifying payments (10 years)
    def calculate_pslf
      total_required = 120
      remaining_payments = [ total_required - @payments_made, 0 ].max
      monthly_rate = @annual_rate / 12.0
      payment = idr_monthly_payment

      balance = @loan_balance
      total_paid = 0.0
      months = 0

      remaining_payments.times do
        interest = balance * monthly_rate
        actual = [ payment, balance + interest ].min

        if actual < interest
          balance += (interest - actual)
        else
          balance -= (actual - interest)
        end

        balance = 0.0 if balance < 0.01
        total_paid += actual
        months += 1
        break if balance <= 0.01
      end

      forgiven = [ balance, 0 ].max
      standard_total = calculate_standard_total

      {
        monthly_payment: payment.round(2),
        total_paid: total_paid.round(2),
        forgiven_amount: forgiven.round(2),
        remaining_payments: remaining_payments,
        months_until_forgiveness: months,
        total_with_standard: standard_total.round(2),
        savings: [ (standard_total - total_paid), 0 ].max.round(2),
        tax_on_forgiveness: 0.0
      }
    end

    # IDR forgiveness after 20 or 25 years
    def calculate_idr(years)
      total_required = years * 12
      remaining_payments = [ total_required - @payments_made, 0 ].max
      monthly_rate = @annual_rate / 12.0
      payment = idr_monthly_payment

      balance = @loan_balance
      total_paid = 0.0
      months = 0

      remaining_payments.times do
        interest = balance * monthly_rate
        actual = [ payment, balance + interest ].min

        if actual < interest
          balance += (interest - actual)
        else
          balance -= (actual - interest)
        end

        balance = 0.0 if balance < 0.01
        total_paid += actual
        months += 1
        break if balance <= 0.01
      end

      forgiven = [ balance, 0 ].max
      # IDR forgiveness is currently taxable (unlike PSLF)
      estimated_tax_rate = 0.22
      tax_on_forgiveness = (forgiven * estimated_tax_rate).round(2)
      standard_total = calculate_standard_total

      {
        monthly_payment: payment.round(2),
        total_paid: total_paid.round(2),
        forgiven_amount: forgiven.round(2),
        remaining_payments: remaining_payments,
        months_until_forgiveness: months,
        total_with_standard: standard_total.round(2),
        savings: [ (standard_total - total_paid - tax_on_forgiveness), 0 ].max.round(2),
        tax_on_forgiveness: tax_on_forgiveness
      }
    end

    # Standard 10-year repayment total for comparison
    def calculate_standard_total
      monthly_rate = @annual_rate / 12.0
      n = 120

      if monthly_rate.zero?
        monthly_payment = @loan_balance / n
      else
        monthly_payment = @loan_balance * (monthly_rate * (1 + monthly_rate)**n) /
                          ((1 + monthly_rate)**n - 1)
      end

      monthly_payment * n
    end
  end
end
