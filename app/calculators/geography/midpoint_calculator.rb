# frozen_string_literal: true

module Geography
  class MidpointCalculator
    attr_reader :errors

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
      lambda1 = to_rad(@lon1)
      dlambda = to_rad(@lon2 - @lon1)

      bx = Math.cos(phi2) * Math.cos(dlambda)
      by = Math.cos(phi2) * Math.sin(dlambda)

      mid_lat = Math.atan2(
        Math.sin(phi1) + Math.sin(phi2),
        Math.sqrt((Math.cos(phi1) + bx)**2 + by**2)
      )
      mid_lon = lambda1 + Math.atan2(by, Math.cos(phi1) + bx)
      mid_lon_deg = ((to_deg(mid_lon) + 540) % 360) - 180

      {
        valid: true,
        midpoint_lat: to_deg(mid_lat).round(6),
        midpoint_lon: mid_lon_deg.round(6)
      }
    end

    private

    def to_rad(deg)
      deg * Math::PI / 180.0
    end

    def to_deg(rad)
      rad * 180.0 / Math::PI
    end

    def validate!
      @errors << "Latitude 1 must be between -90 and 90" unless @lat1.between?(-90, 90)
      @errors << "Latitude 2 must be between -90 and 90" unless @lat2.between?(-90, 90)
      @errors << "Longitude 1 must be between -180 and 180" unless @lon1.between?(-180, 180)
      @errors << "Longitude 2 must be between -180 and 180" unless @lon2.between?(-180, 180)
    end
  end
end
