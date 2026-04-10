# frozen_string_literal: true

module Construction
  class WoodMoistureCalculator
    attr_reader :errors

    def initialize(wet_weight:, dry_weight:)
      @wet_weight = wet_weight.to_f
      @dry_weight = dry_weight.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      moisture_content = ((@wet_weight - @dry_weight) / @dry_weight) * 100.0
      water_weight = @wet_weight - @dry_weight
      category = categorize(moisture_content)
      suitable_for = suitability_for(category)

      {
        valid: true,
        wet_weight: @wet_weight,
        dry_weight: @dry_weight,
        moisture_content: moisture_content.round(2),
        water_weight: water_weight.round(4),
        category: category,
        suitable_for: suitable_for
      }
    end

    private

    def validate!
      @errors << "Wet weight must be greater than zero" unless @wet_weight.positive?
      @errors << "Dry weight must be greater than zero" unless @dry_weight.positive?
      if @wet_weight.positive? && @dry_weight.positive? && @wet_weight < @dry_weight
        @errors << "Wet weight must be greater than or equal to dry weight"
      end
    end

    def categorize(mc)
      if mc > 30
        "Green (above fiber saturation point)"
      elsif mc >= 19 && mc <= 30
        "Wet / shipping dry"
      elsif mc >= 14 && mc < 19
        "Air-dry"
      elsif mc >= 6 && mc < 14
        "Kiln-dry (interior use)"
      else
        "Very dry / over-dried"
      end
    end

    def suitability_for(category)
      case category
      when "Green (above fiber saturation point)"
        "Not ready for use — continue drying before milling or joinery"
      when "Wet / shipping dry"
        "Not ready for interior use — continue drying"
      when "Air-dry"
        "Suitable for exterior use, outdoor furniture, and rough carpentry"
      when "Kiln-dry (interior use)"
        "Suitable for indoor furniture, cabinetry, and flooring"
      when "Very dry / over-dried"
        "Risk of checking and cracking — allow to re-equilibrate with ambient humidity"
      end
    end
  end
end
