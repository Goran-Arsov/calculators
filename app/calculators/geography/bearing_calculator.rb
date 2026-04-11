# frozen_string_literal: true

module Geography
  class BearingCalculator
    attr_reader :errors

    COMPASS_POINTS = %w[N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW].freeze

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
      dlambda = to_rad(@lon2 - @lon1)

      y = Math.sin(dlambda) * Math.cos(phi2)
      x = Math.cos(phi1) * Math.sin(phi2) -
          Math.sin(phi1) * Math.cos(phi2) * Math.cos(dlambda)

      initial_bearing = (to_deg(Math.atan2(y, x)) + 360) % 360
      back_bearing = (initial_bearing + 180) % 360

      {
        valid: true,
        initial_bearing: initial_bearing.round(2),
        back_bearing: back_bearing.round(2),
        compass: compass_point(initial_bearing),
        back_compass: compass_point(back_bearing)
      }
    end

    private

    def to_rad(deg)
      deg * Math::PI / 180.0
    end

    def to_deg(rad)
      rad * 180.0 / Math::PI
    end

    def compass_point(bearing)
      index = ((bearing / 22.5) + 0.5).floor % 16
      COMPASS_POINTS[index]
    end

    def validate!
      @errors << "Latitude 1 must be between -90 and 90" unless @lat1.between?(-90, 90)
      @errors << "Latitude 2 must be between -90 and 90" unless @lat2.between?(-90, 90)
      @errors << "Longitude 1 must be between -180 and 180" unless @lon1.between?(-180, 180)
      @errors << "Longitude 2 must be between -180 and 180" unless @lon2.between?(-180, 180)
      if @lat1 == @lat2 && @lon1 == @lon2
        @errors << "Points must be different to compute a bearing"
      end
    end
  end
end
