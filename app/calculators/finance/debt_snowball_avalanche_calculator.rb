# frozen_string_literal: true

module Finance
  class DebtSnowballAvalancheCalculator
    attr_reader :errors

    # debts: array of hashes { name:, balance:, rate:, minimum_payment: }
    # extra_payment: additional monthly amount beyond minimums
    def initialize(debts:, extra_payment: 0)
      @debts = debts.map do |d|
        {
          name: d[:name].to_s,
          balance: d[:balance].to_f,
          rate: d[:rate].to_f / 100.0,
          minimum_payment: d[:minimum_payment].to_f
        }
      end
      @extra_payment = extra_payment.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      snowball_result = simulate_payoff(sort_snowball)
      avalanche_result = simulate_payoff(sort_avalanche)

      interest_saved = snowball_result[:total_interest] - avalanche_result[:total_interest]
      months_saved = snowball_result[:total_months] - avalanche_result[:total_months]

      {
        valid: true,
        snowball: snowball_result,
        avalanche: avalanche_result,
        interest_saved_by_avalanche: interest_saved.round(2),
        months_saved_by_avalanche: months_saved,
        recommended: interest_saved > 0 ? "avalanche" : "snowball"
      }
    end

    private

    def validate!
      @errors << "At least one debt is required" if @debts.empty?
      @errors << "Extra payment cannot be negative" if @extra_payment < 0

      @debts.each_with_index do |d, i|
        @errors << "Debt #{i + 1} balance must be positive" unless d[:balance] > 0
        @errors << "Debt #{i + 1} interest rate cannot be negative" if d[:rate] < 0
        @errors << "Debt #{i + 1} minimum payment must be positive" unless d[:minimum_payment] > 0
      end
    end

    def sort_snowball
      @debts.sort_by { |d| [ d[:balance], -d[:rate] ] }
    end

    def sort_avalanche
      @debts.sort_by { |d| [ -d[:rate], d[:balance] ] }
    end

    def simulate_payoff(ordered_debts)
      balances = ordered_debts.map { |d| d[:balance] }
      rates = ordered_debts.map { |d| d[:rate] }
      minimums = ordered_debts.map { |d| d[:minimum_payment] }

      total_interest = 0.0
      month = 0
      max_months = 1200 # 100 years safety cap

      while balances.any? { |b| b > 0 } && month < max_months
        month += 1
        extra_remaining = @extra_payment

        # Apply interest first
        balances.each_with_index do |bal, i|
          next if bal <= 0

          interest = bal * rates[i] / 12.0
          total_interest += interest
          balances[i] += interest
        end

        # Pay minimums
        balances.each_with_index do |bal, i|
          next if bal <= 0

          payment = [ minimums[i], bal ].min
          balances[i] -= payment
        end

        # Apply extra payment to first non-zero balance in priority order
        ordered_debts.each_index do |i|
          break if extra_remaining <= 0
          next if balances[i] <= 0

          payment = [ extra_remaining, balances[i] ].min
          balances[i] -= payment
          extra_remaining -= payment
        end
      end

      total_paid = @debts.sum { |d| d[:balance] } + total_interest

      {
        total_months: month,
        total_interest: total_interest.round(2),
        total_paid: total_paid.round(2)
      }
    end
  end
end
