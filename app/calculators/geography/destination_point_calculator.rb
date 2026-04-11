# frozen_string_literal: true

module Geography
  class DestinationPointCalculator
    attr_reader :errors

    EARTH_RADIUS_KM = 6371.0088

    def initialize(lat:, lon:, bearing:, distance:, distance_unit: "km")
      @lat = lat.to_f
      @lon = lon.to_f
      @bearing = bearing.to_f
      @distance = distance.to_f
      @distance_unit = distance_unit.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      distance_km = convert_to_km(@distance, @distance_unit)
      angular_distance = distance_km / EARTH_RADIUS_KM

      phi1 = to_rad(@lat)
      lambda1 = to_rad(@lon)
      theta = to_rad(@bearing)

      phi2 = Math.asin(
        Math.sin(phi1) * Math.cos(angular_distance) +
        Math.cos(phi1) * Math.sin(angular_distance) * Math.cos(theta)
      )
      lambda2 = lambda1 + Math.atan2(
        Math.sin(theta) * Math.sin(angular_distance) * Math.cos(phi1),
        Math.cos(angular_distance) - Math.sin(phi1) * Math.sin(phi2)
      )

      destination_lat = to_deg(phi2)
      destination_lon = ((to_deg(lambda2) + 540) % 360) - 180

      {
        valid: true,
        destination_lat: destination_lat.round(6),
        destination_lon: destination_lon.round(6),
        distance_km: distance_km.round(3)
      }
    end

    private

    def convert_to_km(value, unit)
      case unit
      when "km" then value
      when "mi" then value * 1.609344
      when "nmi" then value * 1.852
      when "m" then value / 1000.0
      else 0.0
      end
    end

    def to_rad(deg)
      deg * Math::PI / 180.0
    end

    def to_deg(rad)
      rad * 180.0 / Math::PI
    end

    def validate!
      @errors << "Latitude must be between -90 and 90" unless @lat.between?(-90, 90)
      @errors << "Longitude must be between -180 and 180" unless @lon.between?(-180, 180)
      @errors << "Bearing must be between 0 and 360" unless @bearing.between?(0, 360)
      @errors << "Distance must be greater than zero" unless @distance.positive?
      @errors << "Distance unit must be km, mi, nmi, or m" unless %w[km mi nmi m].include?(@distance_unit)
    end
  end
end
