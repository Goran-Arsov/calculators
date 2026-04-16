# frozen_string_literal: true

module Finance
  class RentVsBuyCalculator
    attr_reader :errors

    def initialize(monthly_rent:, home_price:, down_payment_pct:, interest_rate:, years:, annual_rent_increase: 3)
      @monthly_rent = monthly_rent.to_f
      @home_price = home_price.to_f
      @down_payment_pct = down_payment_pct.to_f / 100.0
      @interest_rate = interest_rate.to_f / 100.0
      @years = years.to_i
      @annual_rent_increase = annual_rent_increase.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_rent = calculate_total_rent
      total_buy_cost = calculate_total_buy_cost
      savings = total_rent - total_buy_cost

      {
        valid: true,
        total_rent: total_rent.round(4),
        total_buy_cost: total_buy_cost.round(4),
        savings: savings.round(4),
        cheaper_option: savings > 0 ? "buying" : "renting",
        monthly_rent: @monthly_rent.round(4),
        home_price: @home_price.round(4),
        years: @years
      }
    end

    private

    def calculate_total_rent
      total = 0.0
      current_monthly = @monthly_rent

      @years.times do
        total += current_monthly * 12
        current_monthly *= (1 + @annual_rent_increase)
      end

      total
    end

    def calculate_total_buy_cost
      down_payment = @home_price * @down_payment_pct
      loan_amount = @home_price - down_payment
      monthly_rate = @interest_rate / 12.0
      num_payments = @years * 12

      if monthly_rate.zero?
        monthly_payment = num_payments > 0 ? loan_amount / num_payments : 0.0
      else
        monthly_payment = loan_amount * (monthly_rate * (1 + monthly_rate)**num_payments) /
                          ((1 + monthly_rate)**num_payments - 1)
      end

      total_mortgage_payments = monthly_payment * num_payments
      down_payment + total_mortgage_payments
    end

    def validate!
      @errors << "Monthly rent must be positive" unless @monthly_rent > 0
      @errors << "Home price must be positive" unless @home_price > 0
      @errors << "Down payment percentage must be between 0 and 100" unless @down_payment_pct >= 0 && @down_payment_pct < 1.0
      @errors << "Interest rate cannot be negative" if @interest_rate < 0
      @errors << "Years must be positive" unless @years > 0
      @errors << "Annual rent increase cannot be negative" if @annual_rent_increase < 0
    end
  end
end
