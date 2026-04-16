# frozen_string_literal: true

module Finance
  class BondYieldCalculator
    attr_reader :errors

    def initialize(face_value:, coupon_rate:, market_price:, years_to_maturity:, payments_per_year: 2)
      @face_value = face_value.to_f
      @coupon_rate = coupon_rate.to_f / 100.0
      @market_price = market_price.to_f
      @years_to_maturity = years_to_maturity.to_f
      @payments_per_year = payments_per_year.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      annual_coupon = @face_value * @coupon_rate
      coupon_payment = annual_coupon / @payments_per_year

      current_yield = annual_coupon / @market_price * 100.0

      ytm = calculate_ytm(coupon_payment)

      {
        valid: true,
        current_yield: current_yield.round(4),
        yield_to_maturity: (ytm * 100.0).round(4),
        annual_coupon: annual_coupon.round(2),
        coupon_payment: coupon_payment.round(2),
        face_value: @face_value.round(2),
        market_price: @market_price.round(2),
        is_premium: @market_price > @face_value,
        is_discount: @market_price < @face_value
      }
    end

    private

    def validate!
      @errors << "Face value must be positive" unless @face_value > 0
      @errors << "Coupon rate cannot be negative" if @coupon_rate < 0
      @errors << "Market price must be positive" unless @market_price > 0
      @errors << "Years to maturity must be positive" unless @years_to_maturity > 0
      @errors << "Payments per year must be positive" unless @payments_per_year > 0
    end

    # Newton's method to approximate YTM
    def calculate_ytm(coupon_payment)
      n = (@years_to_maturity * @payments_per_year).to_i
      # Initial guess using approximation formula
      ytm_guess = (coupon_payment + (@face_value - @market_price) / n) /
                  ((@face_value + @market_price) / 2.0)

      100.times do
        price = bond_price(ytm_guess, coupon_payment, n)
        dprice = bond_price_derivative(ytm_guess, coupon_payment, n)

        break if dprice.abs < 1e-15

        adjustment = (price - @market_price) / dprice
        ytm_guess -= adjustment

        break if adjustment.abs < 1e-10
      end

      ytm_guess * @payments_per_year
    end

    def bond_price(r, coupon, n)
      return coupon * n + @face_value if r.abs < 1e-15

      pv_coupons = coupon * (1 - (1 + r)**(-n)) / r
      pv_face = @face_value / (1 + r)**n
      pv_coupons + pv_face
    end

    def bond_price_derivative(r, coupon, n)
      return -coupon * n * (n + 1) / 2.0 if r.abs < 1e-15

      dr = 1e-8
      (bond_price(r + dr, coupon, n) - bond_price(r - dr, coupon, n)) / (2 * dr)
    end
  end
end
