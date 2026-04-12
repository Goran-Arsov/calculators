module Automotive
  class CarPaymentTotalCostCalculator
    attr_reader :errors

    def initialize(vehicle_price:, down_payment:, loan_rate:, loan_term_months:,
                   annual_insurance:, monthly_fuel:, annual_maintenance:,
                   annual_registration: 0, sales_tax_rate: 0, ownership_years: 5)
      @vehicle_price = vehicle_price.to_f
      @down_payment = down_payment.to_f
      @loan_rate = loan_rate.to_f / 100.0
      @loan_term_months = loan_term_months.to_i
      @annual_insurance = annual_insurance.to_f
      @monthly_fuel = monthly_fuel.to_f
      @annual_maintenance = annual_maintenance.to_f
      @annual_registration = annual_registration.to_f
      @sales_tax_rate = sales_tax_rate.to_f / 100.0
      @ownership_years = ownership_years.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      sales_tax = @vehicle_price * @sales_tax_rate
      loan_amount = @vehicle_price + sales_tax - @down_payment
      monthly_rate = @loan_rate / 12.0

      if monthly_rate.zero?
        monthly_payment = @loan_term_months > 0 ? loan_amount / @loan_term_months : 0
      else
        monthly_payment = loan_amount * (monthly_rate * (1 + monthly_rate)**@loan_term_months) /
                          ((1 + monthly_rate)**@loan_term_months - 1)
      end

      total_loan_payments = monthly_payment * @loan_term_months
      total_interest = total_loan_payments - loan_amount
      ownership_months = @ownership_years * 12

      total_insurance = @annual_insurance * @ownership_years
      total_fuel = @monthly_fuel * ownership_months
      total_maintenance = @annual_maintenance * @ownership_years
      total_registration = @annual_registration * @ownership_years

      total_cost_of_ownership = @down_payment + total_loan_payments + total_insurance +
                                total_fuel + total_maintenance + total_registration
      monthly_cost_of_ownership = ownership_months > 0 ? total_cost_of_ownership / ownership_months : 0

      {
        valid: true,
        vehicle_price: @vehicle_price.round(2),
        down_payment: @down_payment.round(2),
        sales_tax: sales_tax.round(2),
        loan_amount: loan_amount.round(2),
        monthly_payment: monthly_payment.round(2),
        total_interest: total_interest.round(2),
        total_loan_payments: total_loan_payments.round(2),
        total_insurance: total_insurance.round(2),
        total_fuel: total_fuel.round(2),
        total_maintenance: total_maintenance.round(2),
        total_registration: total_registration.round(2),
        total_cost_of_ownership: total_cost_of_ownership.round(2),
        monthly_cost_of_ownership: monthly_cost_of_ownership.round(2),
        ownership_years: @ownership_years
      }
    end

    private

    def validate!
      @errors << "Vehicle price must be positive" unless @vehicle_price > 0
      @errors << "Down payment cannot be negative" if @down_payment < 0
      @errors << "Down payment cannot exceed vehicle price" if @down_payment > @vehicle_price
      @errors << "Loan rate cannot be negative" if @loan_rate < 0
      @errors << "Loan term must be positive" unless @loan_term_months > 0
      @errors << "Annual insurance cannot be negative" if @annual_insurance < 0
      @errors << "Monthly fuel cost cannot be negative" if @monthly_fuel < 0
      @errors << "Annual maintenance cannot be negative" if @annual_maintenance < 0
      @errors << "Ownership years must be positive" unless @ownership_years > 0
    end
  end
end
