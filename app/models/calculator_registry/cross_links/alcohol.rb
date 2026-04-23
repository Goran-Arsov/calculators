# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    ALCOHOL = {
      "abv-calculator" => %w[cocktail-abv-calculator ibu-calculator srm-beer-color-calculator],
      "ibu-calculator" => %w[abv-calculator srm-beer-color-calculator yeast-pitch-rate-calculator],
      "srm-beer-color-calculator" => %w[abv-calculator ibu-calculator yeast-pitch-rate-calculator],
      "strike-water-temperature-calculator" => %w[hydrometer-temperature-correction-calculator yeast-pitch-rate-calculator brix-to-gravity-refractometer-converter],
      "hydrometer-temperature-correction-calculator" => %w[brix-to-gravity-refractometer-converter abv-calculator strike-water-temperature-calculator],
      "brix-to-gravity-refractometer-converter" => %w[hydrometer-temperature-correction-calculator abv-calculator yeast-pitch-rate-calculator],
      "yeast-pitch-rate-calculator" => %w[abv-calculator priming-sugar-calculator strike-water-temperature-calculator],
      "priming-sugar-calculator" => %w[keg-force-carbonation-calculator abv-calculator yeast-pitch-rate-calculator],
      "keg-force-carbonation-calculator" => %w[priming-sugar-calculator pressure-converter abv-calculator],
      "distiller-proofing-dilution-calculator" => %w[abv-calculator cocktail-abv-calculator pour-cost-calculator],
      "cocktail-abv-calculator" => %w[abv-calculator bac-calculator alcohol-burnoff-calculator],
      "pour-cost-calculator" => %w[cocktail-abv-calculator profit-margin-calculator markup-margin-calculator]
    }.freeze
  end
end
