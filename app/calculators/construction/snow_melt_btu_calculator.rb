# frozen_string_literal: true

module Construction
  class SnowMeltBtuCalculator
    attr_reader :errors

    # ASHRAE 2015 HVAC Applications, Chapter 51 — snow melting systems.
    # Required heat output depends on:
    #   - Snow rate (inches per hour)
    #   - Air temperature (°F)
    #   - Wind speed
    #   - Desired surface condition (Class I: residential, no snow on surface;
    #     Class II: commercial, thin layer OK; Class III: industrial, snow accumulation allowed)
    #
    # Typical design BTU/hr per sq ft from ASHRAE for common climates and
    # Class I (dry pavement, residential driveway/walkway) at moderate wind:
    CLIMATE_BTU = {
      "mild"     => 100, # Seattle, Portland OR
      "moderate" => 125, # Denver, NYC, Chicago
      "cold"     => 150, # Minneapolis, Buffalo
      "severe"   => 200  # Anchorage, International Falls
    }.freeze

    # Heat loss to the back of the slab (downward) for insulated install.
    BACK_LOSS_FACTOR = 1.15

    def initialize(area_sqft:, climate: "moderate")
      @area = area_sqft.to_f
      @climate = climate.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      btu_per_sqft = CLIMATE_BTU[@climate]
      surface_btu = @area * btu_per_sqft
      total_btu = surface_btu * BACK_LOSS_FACTOR
      watts = total_btu / 3.412
      boiler_size_input = total_btu / 0.85 # account for 85% boiler efficiency

      {
        valid: true,
        area_sqft: @area.round(2),
        btu_per_sqft: btu_per_sqft,
        surface_btu_hr: surface_btu.round(0),
        total_btu_hr: total_btu.round(0),
        total_watts: watts.round(0),
        total_kw: (watts / 1000.0).round(2),
        boiler_input_btu_hr: boiler_size_input.round(0)
      }
    end

    private

    def validate!
      @errors << "Area must be greater than zero" unless @area.positive?
      @errors << "Climate must be mild, moderate, cold, or severe" unless CLIMATE_BTU.key?(@climate)
    end
  end
end
