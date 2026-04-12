namespace :automotive do
  get "mpg-calculator", to: "calculators#mpg", as: :mpg
  get "car-depreciation-calculator", to: "calculators#car_depreciation", as: :car_depreciation
  get "tire-size-comparison-calculator", to: "calculators#tire_size_comparison", as: :tire_size_comparison
  get "zero-to-sixty-calculator", to: "calculators#zero_to_sixty", as: :zero_to_sixty
  get "engine-horsepower-calculator", to: "calculators#engine_horsepower", as: :engine_horsepower
  get "oil-change-interval-calculator", to: "calculators#oil_change_interval", as: :oil_change_interval
  get "car-payment-total-cost-calculator", to: "calculators#car_payment_total_cost", as: :car_payment_total_cost
  get "towing-capacity-calculator", to: "calculators#towing_capacity", as: :towing_capacity
  get "ev-range-calculator", to: "calculators#ev_range", as: :ev_range
  get "ev-charging-cost-calculator", to: "calculators#ev_charging_cost", as: :ev_charging_cost
  get "ev-vs-gas-comparison-calculator", to: "calculators#ev_vs_gas_comparison", as: :ev_vs_gas_comparison
end
