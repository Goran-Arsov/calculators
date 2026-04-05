# frozen_string_literal: true

module Everyday
  class ElectricityBillCalculator
    attr_reader :errors

    DAYS_PER_MONTH = 30

    def initialize(watts:, hours_per_day:, rate_per_kwh:, quantity: 1)
      @watts_str = watts.to_s
      @hours_str = hours_per_day.to_s
      @rate_per_kwh = rate_per_kwh.to_f
      @quantity_str = quantity.to_s
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      watts_list = @watts_str.split(",").map(&:strip).map(&:to_f)
      hours_list = @hours_str.split(",").map(&:strip).map(&:to_f)
      quantity_list = @quantity_str.split(",").map(&:strip).map(&:to_i)

      appliances = []
      total_daily_kwh = 0.0

      watts_list.each_with_index do |w, i|
        h = hours_list[i] || 0.0
        q = quantity_list[i] || 1
        q = 1 if q < 1
        daily_kwh = (w * h * q) / 1000.0
        total_daily_kwh += daily_kwh
        appliances << { watts: w, hours: h, quantity: q, daily_kwh: daily_kwh.round(3) }
      end

      monthly_kwh = total_daily_kwh * DAYS_PER_MONTH
      monthly_cost = monthly_kwh * @rate_per_kwh
      yearly_kwh = total_daily_kwh * 365
      yearly_cost = yearly_kwh * @rate_per_kwh

      {
        appliances: appliances,
        total_daily_kwh: total_daily_kwh.round(3),
        monthly_kwh: monthly_kwh.round(2),
        monthly_cost: monthly_cost.round(2),
        yearly_kwh: yearly_kwh.round(2),
        yearly_cost: yearly_cost.round(2)
      }
    end

    private

    def validate!
      watts_list = @watts_str.split(",").map(&:strip)
      hours_list = @hours_str.split(",").map(&:strip)

      @errors << "Watts cannot be empty" if watts_list.empty? || watts_list == [""]
      @errors << "Hours per day cannot be empty" if hours_list.empty? || hours_list == [""]
      return if @errors.any?

      @errors << "Number of wattage entries must match hours entries" if watts_list.size != hours_list.size
      @errors << "Rate per kWh must be greater than zero" unless @rate_per_kwh.positive?

      non_positive_watts = watts_list.select { |w| w.to_f <= 0 }
      @errors << "All wattages must be greater than zero" if non_positive_watts.any?

      invalid_hours = hours_list.select { |h| h.to_f.negative? || h.to_f > 24 }
      @errors << "Hours per day must be between 0 and 24" if invalid_hours.any?
    end
  end
end
