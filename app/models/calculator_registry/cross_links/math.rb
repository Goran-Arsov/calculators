# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    MATH = {
      "scientific-calculator" => %w[base-converter exponent-calculator logarithm-calculator],
      "percentage-calculator" => %w[discount-calculator tip-calculator profit-margin-calculator],
      "percentage-increase-calculator" => %w[percentage-calculator percentage-decrease-calculator percentage-off-calculator],
      "percentage-decrease-calculator" => %w[percentage-calculator percentage-increase-calculator percentage-off-calculator],
      "percentage-off-calculator" => %w[percentage-calculator discount-calculator sale-price-calculator],
      "fraction-calculator" => %w[percentage-calculator gcd-lcm-calculator cooking-converter],
      "area-calculator" => %w[flooring-calculator paint-calculator tile-calculator],
      "circumference-calculator" => %w[area-calculator pythagorean-theorem-calculator aspect-ratio-calculator],
      "exponent-calculator" => %w[logarithm-calculator scientific-notation-calculator base-arithmetic-calculator],
      "pythagorean-theorem-calculator" => %w[area-calculator quadratic-equation-calculator rafter-length-calculator],
      "quadratic-equation-calculator" => %w[pythagorean-theorem-calculator exponent-calculator complex-number-calculator],
      "standard-deviation-calculator" => %w[mean-median-mode-calculator probability-calculator sample-size-calculator],
      "mean-median-mode-calculator" => %w[standard-deviation-calculator probability-calculator gpa-calculator],
      "gcd-lcm-calculator" => %w[fraction-calculator modular-arithmetic-calculator prime-number-checker],
      "sample-size-calculator" => %w[standard-deviation-calculator probability-calculator mean-median-mode-calculator],
      "aspect-ratio-calculator" => %w[area-calculator print-size-dpi-calculator screen-size-calculator],
      "matrix-calculator" => %w[eigenvalue-calculator vector-calculator set-operations-calculator],
      "logarithm-calculator" => %w[exponent-calculator scientific-notation-calculator derivative-calculator],
      "probability-calculator" => %w[permutation-combination-calculator standard-deviation-calculator sample-size-calculator],
      "permutation-combination-calculator" => %w[probability-calculator standard-deviation-calculator gcd-lcm-calculator],
      "base-converter" => %w[base-arithmetic-calculator hex-ascii-converter scientific-notation-calculator],
      "significant-figures-calculator" => %w[scientific-notation-calculator exponent-calculator logarithm-calculator],
      "scientific-notation-calculator" => %w[exponent-calculator logarithm-calculator significant-figures-calculator],
      "integral-calculator" => %w[derivative-calculator limit-calculator taylor-series-calculator],
      "derivative-calculator" => %w[integral-calculator limit-calculator taylor-series-calculator],
      "limit-calculator" => %w[derivative-calculator integral-calculator taylor-series-calculator],
      "taylor-series-calculator" => %w[integral-calculator derivative-calculator logarithm-calculator],
      "complex-number-calculator" => %w[vector-calculator quadratic-equation-calculator matrix-calculator],
      "vector-calculator" => %w[matrix-calculator complex-number-calculator eigenvalue-calculator],
      "eigenvalue-calculator" => %w[matrix-calculator vector-calculator complex-number-calculator],
      "boolean-algebra-simplifier" => %w[base-converter set-operations-calculator modular-arithmetic-calculator],
      "base-arithmetic-calculator" => %w[base-converter hex-ascii-converter modular-arithmetic-calculator],
      "modular-arithmetic-calculator" => %w[gcd-lcm-calculator prime-number-checker base-arithmetic-calculator],
      "set-operations-calculator" => %w[boolean-algebra-simplifier probability-calculator permutation-combination-calculator]
    }.freeze
  end
end
