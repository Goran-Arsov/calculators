# frozen_string_literal: true

module Finance
  class StudentLoanCalculator
    attr_reader :errors

    VALID_PLANS = %w[standard graduated extended income_driven].freeze

    def initialize(balance:, annual_rate:, loan_term_years: 10, plan_type: "standard", monthly_income: 0)
      @balance = balance.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @loan_term_years = loan_term_years.to_i
      @plan_type = plan_type.to_s.downcase.strip
      @monthly_income = monthly_income.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = case @plan_type
      when "standard" then calculate_standard
      when "graduated" then calculate_graduated
      when "extended" then calculate_extended
      when "income_driven" then calculate_income_driven
      end

      result.merge(
        valid: true,
        balance: @balance.round(2),
        annual_rate: (@annual_rate * 100).round(2),
        plan_type: @plan_type
      )
    end

    private

    def validate!
      @errors << "Loan balance must be positive" unless @balance > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
      @errors << "Loan term must be positive" unless @loan_term_years > 0
      @errors << "Invalid plan type" unless VALID_PLANS.include?(@plan_type)
      @errors << "Monthly income required for income-driven plan" if @plan_type == "income_driven" && @monthly_income <= 0
    end

    # Standard: fixed monthly payment over loan term
    def calculate_standard
      monthly_rate = @annual_rate / 12.0
      num_payments = @loan_term_years * 12

      if monthly_rate.zero?
        monthly_payment = @balance / num_payments
      else
        monthly_payment = @balance * (monthly_rate * (1 + monthly_rate)**num_payments) /
                          ((1 + monthly_rate)**num_payments - 1)
      end

      total_paid = monthly_payment * num_payments
      total_interest = total_paid - @balance

      {
        monthly_payment: monthly_payment.round(2),
        total_paid: total_paid.round(2),
        total_interest: total_interest.round(2),
        num_payments: num_payments,
        payoff_months: num_payments
      }
    end

    # Graduated: starts lower, increases every 2 years
    def calculate_graduated
      monthly_rate = @annual_rate / 12.0
      num_payments = @loan_term_years * 12

      # Start at 60% of standard payment, increase 10% every 2 years
      if monthly_rate.zero?
        standard_payment = @balance / num_payments
      else
        standard_payment = @balance * (monthly_rate * (1 + monthly_rate)**num_payments) /
                           ((1 + monthly_rate)**num_payments - 1)
      end

      starting_payment = standard_payment * 0.60
      balance = @balance
      total_paid = 0.0
      month = 0
      current_payment = starting_payment

      while balance > 0.01 && month < num_payments * 2
        if month > 0 && (month % 24).zero?
          current_payment *= 1.10
        end

        interest = balance * monthly_rate
        actual_payment = [ current_payment, balance + interest ].min
        principal = actual_payment - interest
        balance -= principal
        balance = 0.0 if balance < 0.01
        total_paid += actual_payment
        month += 1
      end

      {
        monthly_payment: starting_payment.round(2),
        total_paid: total_paid.round(2),
        total_interest: (total_paid - @balance).round(2),
        num_payments: month,
        payoff_months: month
      }
    end

    # Extended: 25-year term with fixed payments
    def calculate_extended
      extended_years = 25
      monthly_rate = @annual_rate / 12.0
      num_payments = extended_years * 12

      if monthly_rate.zero?
        monthly_payment = @balance / num_payments
      else
        monthly_payment = @balance * (monthly_rate * (1 + monthly_rate)**num_payments) /
                          ((1 + monthly_rate)**num_payments - 1)
      end

      total_paid = monthly_payment * num_payments
      total_interest = total_paid - @balance

      {
        monthly_payment: monthly_payment.round(2),
        total_paid: total_paid.round(2),
        total_interest: total_interest.round(2),
        num_payments: num_payments,
        payoff_months: num_payments
      }
    end

    # Income-driven: 10% of discretionary income (simplified REPAYE/SAVE)
    def calculate_income_driven
      monthly_rate = @annual_rate / 12.0
      annual_income = @monthly_income * 12
      # Discretionary income = income above 150% of federal poverty level (~$22,590 for 2024)
      poverty_line = 22_590.0
      discretionary = [ annual_income - poverty_line * 1.5, 0 ].max
      monthly_payment = (discretionary * 0.10 / 12.0)

      # Simulate payoff (max 20 years for undergrad, we use 20)
      max_months = 240
      balance = @balance
      total_paid = 0.0
      month = 0

      while balance > 0.01 && month < max_months
        interest = balance * monthly_rate
        actual_payment = [ monthly_payment, balance + interest ].min

        if actual_payment < interest
          # Negative amortization capped at balance
          balance += (interest - actual_payment)
        else
          balance -= (actual_payment - interest)
        end

        balance = 0.0 if balance < 0.01
        total_paid += actual_payment
        month += 1
      end

      # Any remaining balance is forgiven after 20 years
      forgiven = [ balance, 0 ].max

      {
        monthly_payment: monthly_payment.round(2),
        total_paid: total_paid.round(2),
        total_interest: (total_paid - @balance + forgiven).round(2),
        num_payments: month,
        payoff_months: month,
        forgiven_amount: forgiven.round(2)
      }
    end
  end
end
