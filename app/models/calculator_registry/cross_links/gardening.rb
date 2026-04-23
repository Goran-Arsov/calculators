# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    GARDENING = {
      "mulch-calculator" => %w[gravel-mulch-calculator topsoil-calculator raised-bed-soil-calculator],
      "topsoil-calculator" => %w[mulch-calculator raised-bed-soil-calculator compost-calculator],
      "raised-bed-soil-calculator" => %w[topsoil-calculator compost-calculator mulch-calculator],
      "compost-calculator" => %w[fertilizer-calculator raised-bed-soil-calculator compost-ratio-calculator],
      "fertilizer-calculator" => %w[compost-calculator grass-seed-calculator plant-spacing-calculator],
      "grass-seed-calculator" => %w[lawn-watering-calculator fertilizer-calculator plant-spacing-calculator],
      "lawn-watering-calculator" => %w[grass-seed-calculator fertilizer-calculator water-intake-calculator],
      "plant-spacing-calculator" => %w[grass-seed-calculator mulch-calculator fertilizer-calculator],
      "growing-degree-days-calculator" => %w[plant-spacing-calculator grass-seed-calculator lawn-watering-calculator],
      "tree-age-calculator" => %w[age-calculator growing-degree-days-calculator dog-age-calculator],
      "greenhouse-heater-calculator" => %w[heat-loss-calculator heating-cost-calculator insulation-calculator],
      "compost-ratio-calculator" => %w[compost-calculator fertilizer-calculator mulch-calculator]
    }.freeze
  end
end
