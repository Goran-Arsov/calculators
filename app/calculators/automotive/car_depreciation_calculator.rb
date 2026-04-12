module Automotive
  class CarDepreciationCalculator
    attr_reader :errors

    def initialize(purchase_price:, vehicle_age_years:, annual_depreciation_rate: 15.0, holding_years: 5)
      @purchase_price = purchase_price.to_f
      @vehicle_age_years = vehicle_age_years.to_i
      @annual_depreciation_rate = annual_depreciation_rate.to_f / 100.0
      @holding_years = holding_years.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # First-year depreciation is typically higher for new cars
      first_year_rate = @vehicle_age_years == 0 ? 0.20 : @annual_depreciation_rate

      # Calculate current value based on vehicle age
      current_value = @purchase_price
      if @vehicle_age_years > 0
        current_value *= (1.0 - first_year_rate) if @vehicle_age_years >= 1
        remaining_years = [ @vehicle_age_years - 1, 0 ].max
        current_value *= (1.0 - @annual_depreciation_rate) ** remaining_years if remaining_years > 0
      end

      # Build year-by-year depreciation schedule for holding period
      schedule = []
      value = current_value
      total_years = @vehicle_age_years

      @holding_years.times do |i|
        year_number = total_years + i + 1
        rate = (total_years == 0 && i == 0) ? first_year_rate : @annual_depreciation_rate
        depreciation_amount = value * rate
        value -= depreciation_amount
        schedule << {
          year: year_number,
          start_value: (value + depreciation_amount).round(2),
          depreciation: depreciation_amount.round(2),
          end_value: value.round(2)
        }
      end

      future_value = schedule.any? ? schedule.last[:end_value] : current_value.round(2)
      total_depreciation = current_value - future_value
      depreciation_percentage = current_value > 0 ? (total_depreciation / current_value * 100.0) : 0.0

      {
        valid: true,
        purchase_price: @purchase_price.round(2),
        current_value: current_value.round(2),
        future_value: future_value.round(2),
        total_depreciation: total_depreciation.round(2),
        depreciation_percentage: depreciation_percentage.round(1),
        holding_years: @holding_years,
        schedule: schedule
      }
    end

    private

    def validate!
      @errors << "Purchase price must be positive" unless @purchase_price > 0
      @errors << "Vehicle age cannot be negative" if @vehicle_age_years < 0
      @errors << "Depreciation rate must be between 0 and 100" unless @annual_depreciation_rate >= 0 && @annual_depreciation_rate <= 1.0
      @errors << "Holding years must be positive" unless @holding_years > 0
    end
  end
end
