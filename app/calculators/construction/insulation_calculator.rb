# frozen_string_literal: true

module Construction
  class InsulationCalculator
    attr_reader :errors

    R_VALUE_TABLE = {
      1 => { attic: 30, wall: 13, floor: 13 },
      2 => { attic: 30, wall: 13, floor: 13 },
      3 => { attic: 38, wall: 13, floor: 19 },
      4 => { attic: 49, wall: 20, floor: 25 },
      5 => { attic: 49, wall: 20, floor: 25 },
      6 => { attic: 60, wall: 21, floor: 30 },
      7 => { attic: 60, wall: 21, floor: 30 }
    }.freeze

    R_PER_INCH = {
      fiberglass_batt: 3.2,
      blown_cellulose: 3.7,
      spray_foam: 6.5
    }.freeze

    COST_PER_SQFT = {
      fiberglass_batt: 0.50,
      blown_cellulose: 0.80,
      spray_foam: 1.50
    }.freeze

    COVERAGE_PER_UNIT = {
      fiberglass_batt: 40.0,
      blown_cellulose: 40.0,
      spray_foam: 40.0
    }.freeze

    VALID_LOCATIONS = %w[attic wall floor].freeze
    VALID_INSULATION_TYPES = %w[fiberglass_batt blown_cellulose spray_foam].freeze

    def initialize(area_sqft:, climate_zone:, location:, insulation_type:)
      @area_sqft = area_sqft.to_f
      @climate_zone = climate_zone.to_i
      @location = location.to_s.strip
      @insulation_type = insulation_type.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      location_sym = @location.to_sym
      type_sym = @insulation_type.to_sym

      required_r_value = R_VALUE_TABLE[@climate_zone][location_sym]
      r_per_inch = R_PER_INCH[type_sym]
      thickness_inches = (required_r_value / r_per_inch).round(1)

      coverage_per_unit = COVERAGE_PER_UNIT[type_sym]
      quantity_needed = (@area_sqft / coverage_per_unit).ceil

      cost_per_sqft = COST_PER_SQFT[type_sym]
      estimated_cost = (@area_sqft * cost_per_sqft).round(2)

      unit_label = case type_sym
      when :fiberglass_batt then "rolls"
      when :blown_cellulose then "bags"
      when :spray_foam then "units (board-foot coverage)"
      end

      {
        valid: true,
        required_r_value: required_r_value,
        thickness_inches: thickness_inches,
        quantity_needed: quantity_needed,
        unit_label: unit_label,
        estimated_cost: estimated_cost
      }
    end

    private

    def validate!
      @errors << "Area must be greater than zero" unless @area_sqft.positive?
      @errors << "Climate zone must be between 1 and 7" unless (1..7).cover?(@climate_zone)
      @errors << "Location must be attic, wall, or floor" unless VALID_LOCATIONS.include?(@location)
      @errors << "Insulation type must be fiberglass_batt, blown_cellulose, or spray_foam" unless VALID_INSULATION_TYPES.include?(@insulation_type)
    end
  end
end
