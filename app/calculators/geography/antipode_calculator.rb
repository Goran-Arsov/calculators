# frozen_string_literal: true

module Geography
  class AntipodeCalculator
    attr_reader :errors

    def initialize(lat:, lon:)
      @lat = lat.to_f
      @lon = lon.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      antipode_lat = -@lat
      antipode_lon = @lon + 180.0
      antipode_lon -= 360.0 if antipode_lon > 180.0
      antipode_lon += 360.0 if antipode_lon < -180.0

      {
        valid: true,
        antipode_lat: antipode_lat.round(6),
        antipode_lon: antipode_lon.round(6),
        hemisphere_lat: antipode_lat.negative? ? "S" : "N",
        hemisphere_lon: antipode_lon.negative? ? "W" : "E",
        on_land_note: ocean_likely?(antipode_lat, antipode_lon) ? "Likely in ocean" : "Possibly on land"
      }
    end

    private

    def ocean_likely?(lat, lon)
      # Rough heuristic: most antipodes fall in ocean.
      # Only small regions where the antipode is also land (e.g. NZ↔Spain, Argentina↔China).
      # Default to ocean unless in one of a few known land-on-land belts.
      return false if lat.between?(-55, -30) && lon.between?(110, 150) # Pacific Argentine antipode area (Asia-Aus)
      return false if lat.between?(30, 55) && lon.between?(100, 140) # Argentina antipode
      true
    end

    def validate!
      @errors << "Latitude must be between -90 and 90" unless @lat.between?(-90, 90)
      @errors << "Longitude must be between -180 and 180" unless @lon.between?(-180, 180)
    end
  end
end
