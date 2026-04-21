# frozen_string_literal: true

module Finance
  class FourOhOneKCalculator
    include Finance::InflationAdjustment

    attr_reader :errors

    def initialize(current_balance:, annual_contribution:, employer_match_percent:, employer_match_limit:, annual_return:, years_to_retirement:, annual_inflation_rate: nil)
      @current_balance = current_balance.to_f
      @annual_contribution = annual_contribution.to_f
      @employer_match_percent = employer_match_percent.to_f / 100.0
      @employer_match_limit = employer_match_limit.to_f / 100.0
      @annual_return = annual_return.to_f / 100.0
      @years = years_to_retirement.to_i
      @annual_inflation_rate = annual_inflation_rate.nil? ? nil : annual_inflation_rate.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Employer match: match_percent of contribution, up to match_limit of contribution
      employer_annual_match = if @employer_match_limit > 0 && @employer_match_percent > 0
                                [ @annual_contribution * @employer_match_percent,
                                 @annual_contribution * @employer_match_limit ].min
      else
                                0.0
      end

      total_annual_addition = @annual_contribution + employer_annual_match
      balance = @current_balance
      total_contributions = 0.0
      total_employer_match = 0.0
      total_growth = 0.0
      year_by_year = []

      @years.times do |i|
        growth = balance * @annual_return
        balance += growth + total_annual_addition
        total_contributions += @annual_contribution
        total_employer_match += employer_annual_match
        total_growth += growth

        year_by_year << {
          year: i + 1,
          balance: balance.round(2),
          contributions: (total_contributions + @current_balance).round(2),
          employer_match: total_employer_match.round(2),
          growth: total_growth.round(2)
        }
      end

      result = {
        valid: true,
        future_value: balance.round(2),
        total_contributions: total_contributions.round(2),
        total_employer_match: total_employer_match.round(2),
        total_growth: (balance - @current_balance - total_contributions - total_employer_match).round(2),
        current_balance: @current_balance.round(2),
        employer_annual_match: employer_annual_match.round(2),
        years: @years,
        year_by_year: year_by_year
      }
      apply_inflation(result, years: @years, nominal_keys: [ :future_value, :total_growth ])
    end

    private

    def validate!
      @errors << "Current balance cannot be negative" if @current_balance < 0
      @errors << "Annual contribution must be positive" unless @annual_contribution > 0
      @errors << "Employer match percent cannot be negative" if @employer_match_percent < 0
      @errors << "Employer match limit cannot be negative" if @employer_match_limit < 0
      @errors << "Annual return rate cannot be negative" if @annual_return < 0
      @errors << "Years to retirement must be positive" unless @years > 0
      @errors << inflation_rate_error if inflation_rate_error
    end
  end
end
