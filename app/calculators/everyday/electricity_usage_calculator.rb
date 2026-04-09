# frozen_string_literal: true

module Everyday
  class ElectricityUsageCalculator
    attr_reader :errors

    def initialize(cost_per_kwh:, appliances:)
      @cost_per_kwh = cost_per_kwh.to_f
      @appliances = Array(appliances).map do |a|
        {
          name: a[:name].to_s,
          watts: a[:watts].to_f,
          hours_per_day: a[:hours_per_day].to_f
        }
      end
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      per_appliance_breakdown = @appliances.map do |a|
        daily_kwh = (a[:watts] * a[:hours_per_day]) / 1000.0
        monthly_kwh = daily_kwh * 30
        monthly_cost = monthly_kwh * @cost_per_kwh
        {
          name: a[:name],
          watts: a[:watts].round(1),
          hours_per_day: a[:hours_per_day].round(1),
          daily_kwh: daily_kwh.round(3),
          monthly_kwh: monthly_kwh.round(2),
          monthly_cost: monthly_cost.round(2)
        }
      end

      total_daily_kwh = per_appliance_breakdown.sum { |a| a[:daily_kwh] }
      total_monthly_kwh = per_appliance_breakdown.sum { |a| a[:monthly_kwh] }
      total_monthly_cost = per_appliance_breakdown.sum { |a| a[:monthly_cost] }

      {
        valid: true,
        total_daily_kwh: total_daily_kwh.round(3),
        total_monthly_kwh: total_monthly_kwh.round(2),
        total_monthly_cost: total_monthly_cost.round(2),
        per_appliance_breakdown: per_appliance_breakdown
      }
    end

    private

    def validate!
      @errors << "Cost per kWh must be greater than zero" unless @cost_per_kwh.positive?
      @errors << "At least one appliance is required" if @appliances.empty?
      @appliances.each_with_index do |a, i|
        @errors << "Appliance #{i + 1} watts must be positive" unless a[:watts].positive?
        @errors << "Appliance #{i + 1} hours per day must be positive" unless a[:hours_per_day].positive?
      end
    end
  end
end
