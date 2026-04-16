# frozen_string_literal: true

module Finance
  module LoanMath
    # Standard amortization formula for fixed-rate loans.
    # Returns monthly_payment, total_paid, total_interest, and num_payments.
    def calculate_amortization(principal, annual_rate, years)
      monthly_rate = annual_rate / 12.0
      num_payments = years * 12

      if monthly_rate.zero?
        monthly_payment = principal / num_payments
      else
        monthly_payment = principal * (monthly_rate * (1 + monthly_rate)**num_payments) /
                          ((1 + monthly_rate)**num_payments - 1)
      end

      total_paid = monthly_payment * num_payments
      total_interest = total_paid - principal

      {
        monthly_payment: monthly_payment.round(2),
        total_paid: total_paid.round(2),
        total_interest: total_interest.round(2),
        num_payments: num_payments
      }
    end
  end
end
