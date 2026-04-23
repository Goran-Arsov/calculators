# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    TEXTILE = {
      "fabric-yardage-calculator" => %w[seam-allowance-converter fabric-gsm-calculator length-converter],
      "seam-allowance-converter" => %w[fabric-yardage-calculator length-converter knitting-gauge-calculator],
      "knitting-gauge-calculator" => %w[crochet-gauge-calculator knitting-needle-hook-size-converter yarn-yardage-calculator],
      "crochet-gauge-calculator" => %w[knitting-gauge-calculator yarn-yardage-calculator knitting-needle-hook-size-converter],
      "knitting-needle-hook-size-converter" => %w[knitting-gauge-calculator crochet-gauge-calculator yarn-yardage-calculator],
      "yarn-yardage-calculator" => %w[knitting-gauge-calculator crochet-gauge-calculator fabric-yardage-calculator],
      "quilt-backing-calculator" => %w[half-square-triangle-calculator quilt-binding-strips-calculator fabric-yardage-calculator],
      "half-square-triangle-calculator" => %w[quilt-backing-calculator quilt-binding-strips-calculator fabric-yardage-calculator],
      "quilt-binding-strips-calculator" => %w[quilt-backing-calculator half-square-triangle-calculator fabric-yardage-calculator],
      "fabric-gsm-calculator" => %w[fabric-yardage-calculator fabric-shrinkage-calculator weight-converter],
      "fabric-shrinkage-calculator" => %w[fabric-gsm-calculator fabric-yardage-calculator length-converter],
      "cross-stitch-fabric-calculator" => %w[fabric-yardage-calculator knitting-gauge-calculator fabric-gsm-calculator]
    }.freeze
  end
end
