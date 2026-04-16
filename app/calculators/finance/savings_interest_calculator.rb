# frozen_string_literal: true

module Finance
  class SavingsInterestCalculator
    attr_reader :errors

    def initialize(initial_balance:, monthly_deposit:, annual_rate:, years:)
      @initial_balance = initial_balance.to_f
      @monthly_deposit = monthly_deposit.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @years = years.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      monthly_rate = @annual_rate / 12.0
      total_months = @years * 12

      # Future value of initial balance: FV = PV * (1 + r)^n
      # Future value of annuity (monthly deposits): FV = PMT * [((1 + r)^n - 1) / r]
      if monthly_rate.zero?
        fv_initial = @initial_balance
        fv_deposits = @monthly_deposit * total_months
      else
        fv_initial = @initial_balance * (1 + monthly_rate)**total_months
        fv_deposits = @monthly_deposit * (((1 + monthly_rate)**total_months - 1) / monthly_rate)
      end

      future_value = fv_initial + fv_deposits
      total_deposits = @monthly_deposit * total_months
      total_contributions = @initial_balance + total_deposits
      total_interest = future_value - total_contributions

      # Year-by-year breakdown
      yearly_breakdown = []
      balance = @initial_balance
      cumulative_deposits = 0.0
      cumulative_interest = 0.0

      @years.times do |i|
        year_start = balance
        12.times do
          interest = balance * monthly_rate
          balance += interest + @monthly_deposit
          cumulative_interest += interest
          cumulative_deposits += @monthly_deposit
        end

        yearly_breakdown << {
          year: i + 1,
          balance: balance.round(2),
          deposits: cumulative_deposits.round(2),
          interest: cumulative_interest.round(2)
        }
      end

      {
        valid: true,
        future_value: future_value.round(2),
        total_deposits: total_deposits.round(2),
        total_interest: total_interest.round(2),
        total_contributions: total_contributions.round(2),
        initial_balance: @initial_balance.round(2),
        monthly_deposit: @monthly_deposit.round(2),
        years: @years,
        yearly_breakdown: yearly_breakdown
      }
    end

    private

    def validate!
      @errors << "Initial balance cannot be negative" if @initial_balance < 0
      @errors << "Monthly deposit cannot be negative" if @monthly_deposit < 0
      @errors << "Either initial balance or monthly deposit must be positive" if @initial_balance <= 0 && @monthly_deposit <= 0
      @errors << "Annual interest rate cannot be negative" if @annual_rate < 0
      @errors << "Number of years must be positive" unless @years > 0
    end
  end
end
