# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    COOKING = {
      "recipe-scaler" => %w[baking-substitution-calculator cup-converter cooking-converter],
      "baking-substitution-calculator" => %w[recipe-scaler cup-converter sourdough-hydration-calculator],
      "sourdough-hydration-calculator" => %w[pizza-dough-calculator baking-substitution-calculator recipe-scaler],
      "meat-cooking-time-calculator" => %w[smoke-time-calculator cooking-converter recipe-scaler],
      "smoke-time-calculator" => %w[meat-cooking-time-calculator cooking-converter recipe-scaler],
      "pizza-dough-calculator" => %w[sourdough-hydration-calculator recipe-scaler baking-substitution-calculator],
      "canning-altitude-calculator" => %w[meat-cooking-time-calculator freezer-storage-time-calculator baking-substitution-calculator],
      "freezer-storage-time-calculator" => %w[meat-cooking-time-calculator canning-altitude-calculator meal-prep-cost-calculator],
      "meal-prep-cost-calculator" => %w[cost-per-serving-calculator macros-per-recipe-calculator cooking-converter],
      "macros-per-recipe-calculator" => %w[macro-calculator calorie-calculator cost-per-serving-calculator]
    }.freeze
  end
end
