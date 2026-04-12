namespace :math do
  get "percentage-calculator", to: "calculators#percentage", as: :percentage
  get "fraction-calculator", to: "calculators#fraction", as: :fraction
  get "area-calculator", to: "calculators#area", as: :area
  get "circumference-calculator", to: "calculators#circumference", as: :circumference
  get "exponent-calculator", to: "calculators#exponent", as: :exponent
  get "pythagorean-theorem-calculator", to: "calculators#pythagorean", as: :pythagorean
  get "quadratic-equation-calculator", to: "calculators#quadratic", as: :quadratic
  get "standard-deviation-calculator", to: "calculators#standard_deviation", as: :standard_deviation
  get "gcd-lcm-calculator", to: "calculators#gcd_lcm", as: :gcd_lcm
  get "sample-size-calculator", to: "calculators#sample_size", as: :sample_size
  get "aspect-ratio-calculator", to: "calculators#aspect_ratio", as: :aspect_ratio
  get "matrix-calculator", to: "calculators#matrix", as: :matrix
  get "logarithm-calculator", to: "calculators#logarithm", as: :logarithm
  get "probability-calculator", to: "calculators#probability", as: :probability
  get "permutation-combination-calculator", to: "calculators#permutation_combination", as: :permutation_combination
  get "mean-median-mode-calculator", to: "calculators#mean_median_mode", as: :mean_median_mode
  get "base-converter", to: "calculators#base_converter", as: :base_converter
  get "significant-figures-calculator", to: "calculators#sig_figs", as: :sig_figs
  get "scientific-notation-calculator", to: "calculators#scientific_notation", as: :scientific_notation
  get "scientific-calculator", to: "calculators#scientific", as: :scientific
  get "integral-calculator", to: "calculators#integral", as: :integral

  get "derivative-calculator", to: "calculators#derivative", as: :derivative
  get "limit-calculator", to: "calculators#limit", as: :limit
  get "taylor-series-calculator", to: "calculators#taylor_series", as: :taylor_series
  get "complex-number-calculator", to: "calculators#complex_number", as: :complex_number
  get "vector-calculator", to: "calculators#vector", as: :vector
  get "eigenvalue-calculator", to: "calculators#eigenvalue", as: :eigenvalue
  get "boolean-algebra-simplifier", to: "calculators#boolean_algebra", as: :boolean_algebra
  get "base-arithmetic-calculator", to: "calculators#base_arithmetic", as: :base_arithmetic
  get "modular-arithmetic-calculator", to: "calculators#modular_arithmetic", as: :modular_arithmetic
  get "set-operations-calculator", to: "calculators#set_operations", as: :set_operations

  # Micro-calculator variants
  get "percentage-increase-calculator", to: "calculators#percentage_increase", as: :percentage_increase
  get "percentage-decrease-calculator", to: "calculators#percentage_decrease", as: :percentage_decrease
  get "percentage-off-calculator", to: "calculators#percentage_off", as: :percentage_off
end
