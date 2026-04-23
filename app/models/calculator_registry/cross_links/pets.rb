# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    PETS = {
      "cat-age-calculator" => %w[dog-age-calculator cat-food-calculator pet-insurance-roi-calculator],
      "cat-food-calculator" => %w[dog-food-calculator cat-age-calculator pet-medication-dosage-calculator],
      "fish-tank-size-calculator" => %w[pool-volume-calculator volume-converter pet-cost-calculator],
      "pet-insurance-roi-calculator" => %w[pet-cost-calculator roi-calculator dog-food-calculator],
      "pet-medication-dosage-calculator" => %w[medication-dosage-calculator cat-food-calculator dog-food-calculator],
      "puppy-weight-predictor" => %w[dog-age-calculator dog-food-calculator cat-age-calculator],
      "horse-feed-calculator" => %w[dog-food-calculator cat-food-calculator weight-converter]
    }.freeze
  end
end
