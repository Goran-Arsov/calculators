# frozen_string_literal: true

module Geography
  class RhumbLineCalculator
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
      dphi = phi2 - phi1
      dlambda = to_rad(shortest_longitude_delta(@lon2 - @lon1))

      dpsi = Math.log(Math.tan(Math::PI / 4 + phi2 / 2) / Math.tan(Math::PI / 4 + phi1 / 2))
      q = dpsi.abs > 1e-12 ? dphi / dpsi : Math.cos(phi1)

      distance_km = Math.sqrt(dphi**2 + q**2 * dlambda**2) * EARTH_RADIUS_KM
      bearing_rad = Math.atan2(dlambda, dpsi)
      bearing_deg = (to_deg(bearing_rad) + 360) % 360

      {
        valid: true,
        distance_km: distance_km.round(3),
        distance_miles: (distance_km * 0.621371).round(3),
        distance_nautical_miles: (distance_km * 0.539957).round(3),
        bearing: bearing_deg.round(2),
        compass: compass_point(bearing_deg)
      }
    end

    private

    def shortest_longitude_delta(delta)
      delta -= 360.0 while delta > 180.0
      delta += 360.0 while delta < -180.0
      delta
    end

    def to_rad(deg)
      deg * Math::PI / 180.0
    end

    def to_deg(rad)
      rad * 180.0 / Math::PI
    end

    def compass_point(bearing)
      points = %w[N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW]
      index = ((bearing / 22.5) + 0.5).floor % 16
      points[index]
    end

    def validate!
      @errors << "Latitude 1 must be between -90 and 90" unless @lat1.between?(-90, 90)
      @errors << "Latitude 2 must be between -90 and 90" unless @lat2.between?(-90, 90)
      @errors << "Longitude 1 must be between -180 and 180" unless @lon1.between?(-180, 180)
      @errors << "Longitude 2 must be between -180 and 180" unless @lon2.between?(-180, 180)
    end
  end
end
