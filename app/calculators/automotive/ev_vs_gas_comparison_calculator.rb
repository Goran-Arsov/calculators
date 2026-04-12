module Automotive
  class EvVsGasComparisonCalculator
    attr_reader :errors

    def initialize(annual_miles:, gas_mpg:, gas_price_per_gallon:, ev_efficiency_kwh_per_100mi:,
                   electricity_rate_per_kwh:, ev_annual_maintenance: 500, gas_annual_maintenance: 1200,
                   comparison_years: 5, ev_purchase_price: 0, gas_purchase_price: 0)
      @annual_miles = annual_miles.to_f
      @gas_mpg = gas_mpg.to_f
      @gas_price = gas_price_per_gallon.to_f
      @ev_efficiency = ev_efficiency_kwh_per_100mi.to_f
      @electricity_rate = electricity_rate_per_kwh.to_f
      @ev_maintenance = ev_annual_maintenance.to_f
      @gas_maintenance = gas_annual_maintenance.to_f
      @comparison_years = comparison_years.to_i
      @ev_price = ev_purchase_price.to_f
      @gas_price_purchase = gas_purchase_price.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Annual fuel costs
      gas_gallons_per_year = @annual_miles / @gas_mpg
      gas_fuel_cost_annual = gas_gallons_per_year * @gas_price

      ev_kwh_per_year = (@annual_miles / 100.0) * @ev_efficiency
      ev_fuel_cost_annual = ev_kwh_per_year * @electricity_rate

      fuel_savings_annual = gas_fuel_cost_annual - ev_fuel_cost_annual

      # Total cost over comparison period
      gas_total_fuel = gas_fuel_cost_annual * @comparison_years
      ev_total_fuel = ev_fuel_cost_annual * @comparison_years
      gas_total_maintenance = @gas_maintenance * @comparison_years
      ev_total_maintenance = @ev_maintenance * @comparison_years

      gas_total_cost = @gas_price_purchase + gas_total_fuel + gas_total_maintenance
      ev_total_cost = @ev_price + ev_total_fuel + ev_total_maintenance

      total_savings = gas_total_cost - ev_total_cost

      # Cost per mile
      gas_cost_per_mile = @gas_mpg > 0 ? @gas_price / @gas_mpg : 0
      ev_cost_per_mile = @ev_efficiency > 0 ? (@ev_efficiency / 100.0) * @electricity_rate : 0

      # Monthly costs
      gas_monthly_fuel = gas_fuel_cost_annual / 12.0
      ev_monthly_fuel = ev_fuel_cost_annual / 12.0

      # Break-even calculation (if EV costs more upfront)
      price_difference = @ev_price - @gas_price_purchase
      annual_operating_savings = fuel_savings_annual + (@gas_maintenance - @ev_maintenance)
      break_even_years = annual_operating_savings > 0 && price_difference > 0 ?
        price_difference / annual_operating_savings : 0

      # CO2 emissions comparison (lbs CO2)
      # Gas: ~19.6 lbs CO2 per gallon
      # EV: ~0.92 lbs CO2 per kWh (US average grid)
      gas_co2_annual = gas_gallons_per_year * 19.6
      ev_co2_annual = ev_kwh_per_year * 0.92
      co2_savings_annual = gas_co2_annual - ev_co2_annual

      {
        valid: true,
        annual_miles: @annual_miles.round(0),
        gas_fuel_cost_annual: gas_fuel_cost_annual.round(2),
        ev_fuel_cost_annual: ev_fuel_cost_annual.round(2),
        fuel_savings_annual: fuel_savings_annual.round(2),
        gas_total_cost: gas_total_cost.round(2),
        ev_total_cost: ev_total_cost.round(2),
        total_savings: total_savings.round(2),
        gas_cost_per_mile: gas_cost_per_mile.round(3),
        ev_cost_per_mile: ev_cost_per_mile.round(3),
        gas_monthly_fuel: gas_monthly_fuel.round(2),
        ev_monthly_fuel: ev_monthly_fuel.round(2),
        break_even_years: break_even_years.round(1),
        gas_co2_annual_lbs: gas_co2_annual.round(0),
        ev_co2_annual_lbs: ev_co2_annual.round(0),
        co2_savings_annual_lbs: co2_savings_annual.round(0),
        comparison_years: @comparison_years,
        gas_gallons_per_year: gas_gallons_per_year.round(1),
        ev_kwh_per_year: ev_kwh_per_year.round(1)
      }
    end

    private

    def validate!
      @errors << "Annual miles must be positive" unless @annual_miles > 0
      @errors << "Gas MPG must be positive" unless @gas_mpg > 0
      @errors << "Gas price must be positive" unless @gas_price > 0
      @errors << "EV efficiency must be positive" unless @ev_efficiency > 0
      @errors << "Electricity rate must be positive" unless @electricity_rate > 0
      @errors << "Comparison years must be positive" unless @comparison_years > 0
      @errors << "EV maintenance cannot be negative" if @ev_maintenance < 0
      @errors << "Gas maintenance cannot be negative" if @gas_maintenance < 0
    end
  end
end
