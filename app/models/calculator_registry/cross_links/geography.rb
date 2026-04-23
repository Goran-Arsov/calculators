# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    GEOGRAPHY = {
      "coordinate-distance-calculator" => %w[bearing-calculator midpoint-calculator rhumb-line-calculator],
      "latitude-longitude-converter" => %w[coordinate-distance-calculator bearing-calculator degrees-to-kilometers-converter],
      "bearing-calculator" => %w[coordinate-distance-calculator midpoint-calculator rhumb-line-calculator],
      "midpoint-calculator" => %w[coordinate-distance-calculator bearing-calculator destination-point-calculator],
      "map-scale-calculator" => %w[aspect-ratio-calculator length-converter area-calculator],
      "population-density-calculator" => %w[polygon-area-calculator area-calculator cost-of-living-calculator],
      "destination-point-calculator" => %w[bearing-calculator midpoint-calculator coordinate-distance-calculator],
      "antipode-calculator" => %w[coordinate-distance-calculator midpoint-calculator destination-point-calculator],
      "rhumb-line-calculator" => %w[coordinate-distance-calculator bearing-calculator flight-time-calculator],
      "polygon-area-calculator" => %w[area-calculator population-density-calculator map-scale-calculator],
      "hiking-time-calculator" => %w[pace-calculator flight-time-calculator running-pace-zone-calculator],
      "geohash-converter" => %w[coordinate-distance-calculator latitude-longitude-converter bearing-calculator],
      "degrees-to-kilometers-converter" => %w[coordinate-distance-calculator length-converter latitude-longitude-converter],
      "flight-time-calculator" => %w[hiking-time-calculator travel-budget-calculator coordinate-distance-calculator]
    }.freeze
  end
end
