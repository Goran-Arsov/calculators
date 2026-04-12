# frozen_string_literal: true

module Education
  class TuitionSavings529Calculator
    attr_reader :errors

    def initialize(current_balance: 0, monthly_contribution:, annual_return: 6.0, years_until_college:, state_tax_rate: 5.0, annual_contribution_limit: 18_000)
      @current_balance = current_balance.to_f
      @monthly_contribution = monthly_contribution.to_f
      @annual_return = annual_return.to_f / 100.0
      @years_until_college = years_until_college.to_i
      @state_tax_rate = state_tax_rate.to_f / 100.0
      @annual_contribution_limit = annual_contribution_limit.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      monthly_rate = @annual_return / 12.0
      total_months = @years_until_college * 12
      annual_contribution = @monthly_contribution * 12

      # Year-by-year projection
      yearly_projections = []
      balance = @current_balance
      total_contributions = @current_balance
      total_earnings = 0.0

      @years_until_college.times do |year|
        year_start_balance = balance
        year_contributions = 0.0
        year_earnings = 0.0

        12.times do
          interest = balance * monthly_rate
          balance += interest + @monthly_contribution
          year_contributions += @monthly_contribution
          year_earnings += interest
        end

        total_contributions += year_contributions
        total_earnings += year_earnings

        yearly_projections << {
          year: year + 1,
          start_balance: year_start_balance.round(2),
          contributions: year_contributions.round(2),
          earnings: year_earnings.round(2),
          end_balance: balance.round(2)
        }
      end

      final_balance = balance
      total_tax_deduction = annual_contribution * @state_tax_rate * @years_until_college
      tax_free_earnings = total_earnings

      # Estimated college costs for comparison (average 4-year public university)
      avg_annual_college_cost = 25_000.0
      college_inflation_rate = 0.05
      projected_annual_cost = avg_annual_college_cost * (1 + college_inflation_rate)**@years_until_college
      projected_4_year_cost = projected_annual_cost * 4
      coverage_percentage = projected_4_year_cost > 0 ? ((final_balance / projected_4_year_cost) * 100) : 0.0

      {
        valid: true,
        final_balance: final_balance.round(2),
        total_contributions: total_contributions.round(2),
        total_earnings: total_earnings.round(2),
        tax_free_earnings: tax_free_earnings.round(2),
        total_tax_deduction: total_tax_deduction.round(2),
        years_until_college: @years_until_college,
        monthly_contribution: @monthly_contribution.round(2),
        annual_return: (@annual_return * 100).round(2),
        yearly_projections: yearly_projections,
        projected_4_year_cost: projected_4_year_cost.round(2),
        coverage_percentage: coverage_percentage.round(1),
        current_balance: @current_balance.round(2)
      }
    end

    private

    def validate!
      @errors << "Current balance cannot be negative" if @current_balance < 0
      @errors << "Monthly contribution must be positive" unless @monthly_contribution > 0
      @errors << "Annual return rate cannot be negative" if @annual_return < 0
      @errors << "Years until college must be between 1 and 25" unless @years_until_college.between?(1, 25)
      @errors << "State tax rate cannot be negative" if @state_tax_rate < 0
    end
  end
end
