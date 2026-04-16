# frozen_string_literal: true

module Finance
  class DebtPayoffCalculator
    attr_reader :errors

    def initialize(balance:, annual_rate:, monthly_payment:)
      @balance = balance.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @monthly_payment = monthly_payment.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      monthly_rate = @annual_rate / 12.0

      if monthly_rate.zero?
        months = (@balance / @monthly_payment).ceil
      else
        min_payment = @balance * monthly_rate
        if @monthly_payment <= min_payment
          @errors << "Monthly payment must exceed minimum interest charge of #{format('%.2f', min_payment)}"
          return { valid: false, errors: @errors }
        end
        months = (-::Math.log(1 - monthly_rate * @balance / @monthly_payment) / ::Math.log(1 + monthly_rate)).ceil
      end

      total_paid = @monthly_payment * months
      total_interest = total_paid - @balance

      {
        valid: true,
        months_to_payoff: months,
        years_to_payoff: (months / 12.0).round(1),
        total_paid: total_paid.round(2),
        total_interest: total_interest.round(2)
      }
    end

    private

    def validate!
      @errors << "Balance must be positive" unless @balance > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
      @errors << "Monthly payment must be positive" unless @monthly_payment > 0
    end
  end
end
