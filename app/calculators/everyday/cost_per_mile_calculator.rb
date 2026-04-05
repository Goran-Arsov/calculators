# frozen_string_literal: true

module Everyday
  class CostPerMileCalculator
    attr_reader :errors

    KM_PER_MILE = 1.60934

    def initialize(fuel_cost:, insurance_cost:, maintenance_cost:, depreciation_cost:, miles_driven:, other_costs: 0)
      @fuel_cost = fuel_cost.to_f
      @insurance_cost = insurance_cost.to_f
      @maintenance_cost = maintenance_cost.to_f
      @depreciation_cost = depreciation_cost.to_f
      @other_costs = other_costs.to_f
      @miles_driven = miles_driven.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      total_cost = @fuel_cost + @insurance_cost + @maintenance_cost + @depreciation_cost + @other_costs
      cost_per_mile = total_cost / @miles_driven
      km_driven = @miles_driven * KM_PER_MILE
      cost_per_km = total_cost / km_driven
      annual_cost = total_cost

      {
        cost_per_mile: cost_per_mile.round(4),
        cost_per_km: cost_per_km.round(4),
        total_cost: total_cost.round(2),
        annual_cost: annual_cost.round(2),
        miles_driven: @miles_driven.round(1),
        km_driven: km_driven.round(1),
        breakdown: {
          fuel: @fuel_cost.round(2),
          insurance: @insurance_cost.round(2),
          maintenance: @maintenance_cost.round(2),
          depreciation: @depreciation_cost.round(2),
          other: @other_costs.round(2)
        }
      }
    end

    private

    def validate!
      @errors << "Fuel cost cannot be negative" if @fuel_cost.negative?
      @errors << "Insurance cost cannot be negative" if @insurance_cost.negative?
      @errors << "Maintenance cost cannot be negative" if @maintenance_cost.negative?
      @errors << "Depreciation cost cannot be negative" if @depreciation_cost.negative?
      @errors << "Other costs cannot be negative" if @other_costs.negative?
      @errors << "Miles driven must be greater than zero" unless @miles_driven.positive?
      total = @fuel_cost + @insurance_cost + @maintenance_cost + @depreciation_cost + @other_costs
      @errors << "Total costs must be greater than zero" unless total.positive?
    end
  end
end
