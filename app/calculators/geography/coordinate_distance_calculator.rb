# frozen_string_literal: true

module Geography
  class CoordinateDistanceCalculator
    attr_reader :errors

    EARTH_RADIUS_KM = 6371.0088

    def initialize(lat1:, lon1:, lat2:, lon2:)
      @lat1 = lat1.to_f
      @lon1 = lon1.to_f
      @lat2 = lat2.to_f
      @lon2 = lon2.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      phi1 = to_rad(@lat1)
      phi2 = to_rad(@lat2)
      dphi = to_rad(@lat2 - @lat1)
      dlambda = to_rad(@lon2 - @lon1)

      a = Math.sin(dphi / 2)**2 +
          Math.cos(phi1) * Math.cos(phi2) * Math.sin(dlambda / 2)**2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      distance_km = EARTH_RADIUS_KM * c

      {
        valid: true,
        distance_km: distance_km.round(3),
        distance_miles: (distance_km * 0.621371).round(3),
        distance_nautical_miles: (distance_km * 0.539957).round(3),
        distance_meters: (distance_km * 1000).round(1)
      }
    end

    private

    def to_rad(deg)
      deg * Math::PI / 180.0
    end

    def validate!
      @errors << "Latitude 1 must be between -90 and 90" unless @lat1.between?(-90, 90)
      @errors << "Latitude 2 must be between -90 and 90" unless @lat2.between?(-90, 90)
      @errors << "Longitude 1 must be between -180 and 180" unless @lon1.between?(-180, 180)
      @errors << "Longitude 2 must be between -180 and 180" unless @lon2.between?(-180, 180)
    end
  end
end
