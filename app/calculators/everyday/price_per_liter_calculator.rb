# frozen_string_literal: true

module Everyday
  class PricePerLiterCalculator
    attr_reader :errors

    VOLUME_TO_LITERS = {
      "L" => 1.0,
      "mL" => 0.001,
      "gal" => 3.78541,
      "fl_oz" => 0.0295735
    }.freeze

    def initialize(total_price:, volume:, unit: "L")
      @total_price = total_price.to_f
      @volume = volume.to_f
      @unit = unit.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      conversion = VOLUME_TO_LITERS[@unit] || 1.0
      volume_in_liters = @volume * conversion

      price_per_liter = @total_price / volume_in_liters
      price_per_ml = price_per_liter / 1000.0
      price_per_gallon = price_per_liter * 3.78541
      price_per_fl_oz = price_per_liter * 0.0295735

      {
        valid: true,
        price_per_liter: price_per_liter.round(4),
        price_per_ml: price_per_ml.round(6),
        price_per_gallon: price_per_gallon.round(2),
        price_per_fl_oz: price_per_fl_oz.round(4),
        volume_in_liters: volume_in_liters.round(4),
        total_price: @total_price.round(2),
        unit: @unit
      }
    end

    private

    def validate!
      @errors << "Total price must be greater than zero" unless @total_price.positive?
      @errors << "Volume must be greater than zero" unless @volume.positive?
      @errors << "Unit must be L, mL, gal, or fl_oz" unless VOLUME_TO_LITERS.key?(@unit)
    end
  end
end
