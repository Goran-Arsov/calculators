# frozen_string_literal: true

module Pets
  class FishTankCalculator
    attr_reader :errors

    VALID_TANK_SHAPES = %w[rectangular bow_front cylinder hexagonal].freeze
    GALLONS_PER_CUBIC_INCH = 0.004329
    LITERS_PER_GALLON = 3.78541

    # General rule: 1 inch of fish per gallon for freshwater
    INCHES_PER_GALLON = 1.0
    # Filter should turn over tank volume 4x per hour
    FILTER_TURNOVER_RATE = 4
    # Heater: ~5 watts per gallon
    HEATER_WATTS_PER_GALLON = 5

    def initialize(length:, width:, height:, tank_shape: "rectangular", fish_count: 0, avg_fish_inches: 2.0)
      @length = length.to_f
      @width = width.to_f
      @height = height.to_f
      @tank_shape = tank_shape.to_s
      @fish_count = fish_count.to_i
      @avg_fish_inches = avg_fish_inches.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      volume_gallons = calculate_volume_gallons
      volume_liters = volume_gallons * LITERS_PER_GALLON
      max_fish_inches = (volume_gallons * INCHES_PER_GALLON).floor
      current_fish_inches = @fish_count * @avg_fish_inches
      stocking_percentage = volume_gallons > 0 ? (current_fish_inches / (volume_gallons * INCHES_PER_GALLON) * 100) : 0
      stocking_level = determine_stocking_level(stocking_percentage)
      filter_gph = (volume_gallons * FILTER_TURNOVER_RATE).ceil
      heater_watts = (volume_gallons * HEATER_WATTS_PER_GALLON).ceil

      {
        valid: true,
        tank_shape: @tank_shape,
        volume_gallons: volume_gallons.round(1),
        volume_liters: volume_liters.round(1),
        max_fish_inches: max_fish_inches,
        current_fish_inches: current_fish_inches.round(1),
        stocking_percentage: stocking_percentage.round(1),
        stocking_level: stocking_level,
        recommended_filter_gph: filter_gph,
        recommended_heater_watts: heater_watts,
        fish_count: @fish_count,
        avg_fish_inches: @avg_fish_inches
      }
    end

    private

    def calculate_volume_gallons
      cubic_inches = case @tank_shape
      when "rectangular"
        @length * @width * @height
      when "bow_front"
        # Bow front is approximately 1.1x a rectangular tank of same dimensions
        @length * @width * @height * 1.1
      when "cylinder"
        # Length = diameter, width ignored for cylinder
        radius = @length / 2.0
        Math::PI * radius**2 * @height
      when "hexagonal"
        # Regular hexagon: area = (3 * sqrt(3) / 2) * side^2, side ≈ length/2
        side = @length / 2.0
        hex_area = (3 * Math.sqrt(3) / 2.0) * side**2
        hex_area * @height
      else
        @length * @width * @height
      end

      # Subtract ~10% for substrate, decorations, equipment
      effective_cubic_inches = cubic_inches * 0.9
      effective_cubic_inches * GALLONS_PER_CUBIC_INCH
    end

    def determine_stocking_level(percentage)
      case percentage
      when 0...50 then "Under-stocked"
      when 50...75 then "Lightly stocked"
      when 75...100 then "Well stocked"
      when 100...125 then "Fully stocked"
      else "Over-stocked"
      end
    end

    def validate!
      @errors << "Length must be positive" unless @length > 0
      @errors << "Width must be positive" unless @width > 0
      @errors << "Height must be positive" unless @height > 0
      @errors << "Tank shape must be #{VALID_TANK_SHAPES.join(', ')}" unless VALID_TANK_SHAPES.include?(@tank_shape)
      @errors << "Fish count cannot be negative" if @fish_count < 0
      @errors << "Average fish size must be positive" if @fish_count > 0 && @avg_fish_inches <= 0
      @errors << "Tank dimensions seem unrealistically large (max 120 inches per side)" if @length > 120 || @width > 120 || @height > 120
    end
  end
end
