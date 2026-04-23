# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    AUTOMOTIVE = {
      "mpg-calculator" => %w[fuel-cost-calculator gas-mileage-calculator car-payment-total-cost-calculator],
      "car-depreciation-calculator" => %w[auto-loan-calculator car-loan-calculator lease-vs-buy-calculator],
      "tire-size-comparison-calculator" => %w[mpg-calculator engine-horsepower-calculator zero-to-sixty-calculator],
      "zero-to-sixty-calculator" => %w[engine-horsepower-calculator tire-size-comparison-calculator velocity-calculator],
      "engine-horsepower-calculator" => %w[zero-to-sixty-calculator tire-size-comparison-calculator towing-capacity-calculator],
      "oil-change-interval-calculator" => %w[car-payment-total-cost-calculator mpg-calculator car-depreciation-calculator],
      "car-payment-total-cost-calculator" => %w[auto-loan-calculator car-loan-calculator lease-vs-buy-calculator],
      "towing-capacity-calculator" => %w[engine-horsepower-calculator mpg-calculator rv-loan-calculator],
      "ev-range-calculator" => %w[ev-charging-cost-calculator ev-vs-gas-comparison-calculator mpg-calculator],
      "ev-charging-cost-calculator" => %w[ev-range-calculator ev-vs-gas-comparison-calculator electricity-cost-calculator],
      "ev-vs-gas-comparison-calculator" => %w[ev-range-calculator ev-charging-cost-calculator mpg-calculator]
    }.freeze
  end
end
