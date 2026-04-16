# frozen_string_literal: true

class CalculatorRegistry
  AUTOMOTIVE_CALCULATORS = [
    { name: "MPG Calculator", slug: "mpg-calculator", path: :automotive_mpg_path, description: "Calculate your vehicle's miles per gallon from distance traveled and fuel used. Supports imperial and metric.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Car Depreciation Calculator", slug: "car-depreciation-calculator", path: :automotive_car_depreciation_path, description: "Calculate how much your car depreciates each year using the declining balance method with a year-by-year schedule.", icon_path: "M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "Tire Size Comparison Calculator", slug: "tire-size-comparison-calculator", path: :automotive_tire_size_comparison_path, description: "Compare two tire sizes side by side for diameter, circumference, sidewall height, and speedometer difference.", icon_path: "M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "Zero to Sixty Calculator", slug: "zero-to-sixty-calculator", path: :automotive_zero_to_sixty_path, description: "Estimate your vehicle's 0-60 mph time, quarter mile time, and trap speed from horsepower and weight.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Engine Horsepower Calculator", slug: "engine-horsepower-calculator", path: :automotive_engine_horsepower_path, description: "Calculate engine horsepower from torque and RPM, or torque from HP and RPM. Includes kW and Nm conversions.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Oil Change Interval Calculator", slug: "oil-change-interval-calculator", path: :automotive_oil_change_interval_path, description: "Calculate when your next oil change is due based on oil type, mileage, and driving conditions.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Car Payment Total Cost Calculator", slug: "car-payment-total-cost-calculator", path: :automotive_car_payment_total_cost_path, description: "Calculate the true total cost of owning a vehicle including loan, insurance, fuel, maintenance, and registration.", icon_path: "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "Towing Capacity Calculator", slug: "towing-capacity-calculator", path: :automotive_towing_capacity_path, description: "Calculate your vehicle's safe towing weight from GVWR, curb weight, payload, and tongue weight percentage.", icon_path: "M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "EV Range Calculator", slug: "ev-range-calculator", path: :automotive_ev_range_path, description: "Estimate your electric vehicle's real-world range based on battery size, efficiency, speed, and temperature.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "EV Charging Cost Calculator", slug: "ev-charging-cost-calculator", path: :automotive_ev_charging_cost_path, description: "Calculate the cost to charge your EV at home or public chargers with energy, time, and cost per mile.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "EV vs Gas Cost Calculator", slug: "ev-vs-gas-comparison-calculator", path: :automotive_ev_vs_gas_comparison_path, description: "Compare annual and total costs of owning an EV versus a gas car including fuel, maintenance, and CO2 emissions.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" }
  ].freeze

end
