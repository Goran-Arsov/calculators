# frozen_string_literal: true

module Finance
  class BusinessLoanCalculator
    attr_reader :errors

    def initialize(amount:, annual_rate:, years:, origination_fee_percent:)
      @amount = amount.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @years = years.to_i
      @origination_fee_percent = origination_fee_percent.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      monthly_rate = @annual_rate / 12.0
      num_payments = @years * 12

      if monthly_rate.zero?
        monthly_payment = @amount / num_payments
      else
        monthly_payment = @amount * (monthly_rate * (1 + monthly_rate)**num_payments) /
                          ((1 + monthly_rate)**num_payments - 1)
      end

      total_paid = monthly_payment * num_payments
      total_interest = total_paid - @amount
      origination_fee = @amount * @origination_fee_percent
      total_cost = total_paid + origination_fee

      # Effective APR: find the rate where the net proceeds (amount - fee)
      # equal the PV of all monthly payments at that rate
      net_proceeds = @amount - origination_fee
      effective_apr = compute_effective_apr(net_proceeds, monthly_payment, num_payments)

      {
        valid: true,
        monthly_payment: monthly_payment.round(2),
        total_interest: total_interest.round(2),
        total_paid: total_paid.round(2),
        total_cost: total_cost.round(2),
        origination_fee: origination_fee.round(2),
        effective_apr: effective_apr.round(2),
        num_payments: num_payments
      }
    end

    private

    def validate!
      @errors << "Loan amount must be positive" unless @amount > 0
      @errors << "Loan term must be positive" unless @years > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
      @errors << "Origination fee cannot be negative" if @origination_fee_percent < 0
    end

    # Newton's method to find effective APR
    def compute_effective_apr(net_proceeds, monthly_payment, num_payments)
      return 0.0 if net_proceeds <= 0 || monthly_payment <= 0

      # Initial guess: nominal rate
      r = @annual_rate / 12.0
      r = 0.005 if r.zero?

      50.times do
        # PV of annuity at rate r
        pv = monthly_payment * (1.0 - (1.0 + r)**(-num_payments)) / r
        f = pv - net_proceeds

        # Derivative of PV with respect to r
        dpv = monthly_payment * (
          num_payments * (1.0 + r)**(-num_payments - 1) / r -
          (1.0 - (1.0 + r)**(-num_payments)) / (r * r)
        )

        break if dpv.abs < 1e-15

        r_new = r - f / dpv
        r_new = r / 2.0 if r_new <= 0
        break if (r_new - r).abs < 1e-10

        r = r_new
      end

      (r * 12 * 100).round(2)
    end
  end
end
