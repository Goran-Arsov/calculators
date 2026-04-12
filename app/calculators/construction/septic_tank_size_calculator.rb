# frozen_string_literal: true

module Construction
  class SepticTankSizeCalculator
    attr_reader :errors

    BASE_GALLONS = 1000
    GALLONS_PER_ADDITIONAL_BEDROOM = 250
    BASE_BEDROOMS = 3
    GALLONS_PER_PERSON_PER_DAY = 75
    MINIMUM_TANK_GALLONS = 1000

    # Standard tank sizes available (gallons)
    STANDARD_TANK_SIZES = [1000, 1250, 1500, 1750, 2000, 2500, 3000, 3500, 4000, 5000].freeze

    def initialize(bedrooms:, occupants: nil, daily_water_gallons: nil, has_garbage_disposal: false, has_hot_tub: false)
      @bedrooms = bedrooms.to_i
      @occupants = occupants.nil? || occupants.to_s.strip.empty? ? nil : occupants.to_i
      @daily_water_gallons = daily_water_gallons.nil? || daily_water_gallons.to_s.strip.empty? ? nil : daily_water_gallons.to_f
      @has_garbage_disposal = to_bool(has_garbage_disposal)
      @has_hot_tub = to_bool(has_hot_tub)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Method 1: Bedroom-based sizing (most common code requirement)
      if @bedrooms <= BASE_BEDROOMS
        bedroom_based_gallons = BASE_GALLONS
      else
        bedroom_based_gallons = BASE_GALLONS + ((@bedrooms - BASE_BEDROOMS) * GALLONS_PER_ADDITIONAL_BEDROOM)
      end

      # Method 2: Occupant-based sizing
      occupant_count = @occupants || (@bedrooms * 2)
      daily_flow = @daily_water_gallons || (occupant_count * GALLONS_PER_PERSON_PER_DAY)

      # Tank should hold at least 2 days of flow
      flow_based_gallons = (daily_flow * 2).ceil

      # Use the larger of the two methods
      required_gallons = [bedroom_based_gallons, flow_based_gallons, MINIMUM_TANK_GALLONS].max

      # Add capacity for special fixtures
      required_gallons = (required_gallons * 1.10).ceil if @has_garbage_disposal
      required_gallons = (required_gallons * 1.10).ceil if @has_hot_tub

      # Find standard tank size
      recommended_tank = STANDARD_TANK_SIZES.find { |s| s >= required_gallons } || STANDARD_TANK_SIZES.last

      # Drain field estimate: 1 linear ft per gallon per day of flow, varies by soil
      drainfield_linear_ft = (daily_flow / 0.5).round(0)  # Conservative: 0.5 gpd per sqft

      {
        valid: true,
        bedrooms: @bedrooms,
        occupants: occupant_count,
        daily_flow_gallons: daily_flow.round(0),
        bedroom_based_gallons: bedroom_based_gallons,
        flow_based_gallons: flow_based_gallons,
        required_gallons: required_gallons,
        recommended_tank_gallons: recommended_tank,
        drainfield_estimate_ft: drainfield_linear_ft
      }
    end

    private

    def validate!
      @errors << "Bedrooms must be at least 1" unless @bedrooms >= 1
      @errors << "Bedrooms cannot exceed 10" if @bedrooms > 10
      @errors << "Occupants must be positive" if @occupants && @occupants <= 0
      @errors << "Daily water usage must be positive" if @daily_water_gallons && !@daily_water_gallons.positive?
    end

    def to_bool(value)
      return value if value.is_a?(TrueClass) || value.is_a?(FalseClass)

      %w[true 1 yes on].include?(value.to_s.downcase)
    end
  end
end
