# frozen_string_literal: true

module Geography
  class DegreesToKilometersConverter
    attr_reader :errors

    KM_PER_DEGREE_LATITUDE = 111.32

    def initialize(latitude: 0, degrees: 1.0, mode: "degrees_to_km")
      @latitude = latitude.to_f
      @degrees = degrees.to_f
      @mode = mode.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      km_per_deg_lat = KM_PER_DEGREE_LATITUDE
      km_per_deg_lon = KM_PER_DEGREE_LATITUDE * Math.cos(to_rad(@latitude))

      {
        valid: true,
        latitude: @latitude,
        km_per_degree_latitude: km_per_deg_lat.round(4),
        km_per_degree_longitude: km_per_deg_lon.round(4),
        miles_per_degree_latitude: (km_per_deg_lat * 0.621371).round(4),
        miles_per_degree_longitude: (km_per_deg_lon * 0.621371).round(4),
        input_degrees: @degrees,
        input_km_latitude: (@degrees * km_per_deg_lat).round(4),
        input_km_longitude: (@degrees * km_per_deg_lon).round(4),
        input_miles_latitude: (@degrees * km_per_deg_lat * 0.621371).round(4),
        input_miles_longitude: (@degrees * km_per_deg_lon * 0.621371).round(4)
      }
    end

    private

    def to_rad(deg)
      deg * Math::PI / 180.0
    end

    def validate!
      @errors << "Latitude must be between -90 and 90" unless @latitude.between?(-90, 90)
      @errors << "Degrees must be greater than zero" unless @degrees.positive?
    end
  end
end
