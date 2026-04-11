# frozen_string_literal: true

module Geography
  class FlightTimeCalculator
    attr_reader :errors

    EARTH_RADIUS_KM = 6371.0088

    # Typical cruise speeds in km/h for common aircraft classes.
    AIRCRAFT_SPEEDS_KPH = {
      "commercial_jet" => 900,
      "regional_jet" => 780,
      "turboprop" => 520,
      "private_jet" => 780,
      "cessna" => 230,
      "helicopter" => 260
    }.freeze

    DEFAULT_TAXI_MINUTES = 20

    def initialize(lat1: nil, lon1: nil, lat2: nil, lon2: nil,
                   distance_km: nil, cruise_speed_kph: 900,
                   taxi_minutes: DEFAULT_TAXI_MINUTES, aircraft: nil)
      @lat1 = lat1&.to_f
      @lon1 = lon1&.to_f
      @lat2 = lat2&.to_f
      @lon2 = lon2&.to_f
      @distance_km = distance_km&.to_f
      @cruise_speed_kph = if aircraft && AIRCRAFT_SPEEDS_KPH.key?(aircraft.to_s)
                            AIRCRAFT_SPEEDS_KPH[aircraft.to_s]
      else
                            cruise_speed_kph.to_f
      end
      @taxi_minutes = taxi_minutes.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      distance_km = @distance_km || haversine_distance
      air_time_hours = distance_km / @cruise_speed_kph
      taxi_hours = @taxi_minutes / 60.0
      total_hours = air_time_hours + taxi_hours

      {
        valid: true,
        distance_km: distance_km.round(2),
        distance_miles: (distance_km * 0.621371).round(2),
        distance_nautical_miles: (distance_km * 0.539957).round(2),
        air_time_hours: air_time_hours.round(3),
        total_hours: total_hours.round(3),
        total_minutes: (total_hours * 60).round(0),
        formatted_time: format_hm(total_hours),
        cruise_speed_kph: @cruise_speed_kph.round(1)
      }
    end

    private

    def haversine_distance
      phi1 = to_rad(@lat1)
      phi2 = to_rad(@lat2)
      dphi = to_rad(@lat2 - @lat1)
      dlambda = to_rad(@lon2 - @lon1)
      a = Math.sin(dphi / 2)**2 + Math.cos(phi1) * Math.cos(phi2) * Math.sin(dlambda / 2)**2
      2 * EARTH_RADIUS_KM * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    end

    def format_hm(hours)
      h = hours.floor
      m = ((hours - h) * 60).round
      if m == 60
        h += 1
        m = 0
      end
      "#{h}h #{m}m"
    end

    def to_rad(deg)
      deg * Math::PI / 180.0
    end

    def validate!
      if @distance_km.nil?
        if [ @lat1, @lon1, @lat2, @lon2 ].any?(&:nil?)
          @errors << "Provide either distance_km or all four coordinates"
          return
        end
        @errors << "Latitude 1 must be between -90 and 90" unless @lat1.between?(-90, 90)
        @errors << "Latitude 2 must be between -90 and 90" unless @lat2.between?(-90, 90)
        @errors << "Longitude 1 must be between -180 and 180" unless @lon1.between?(-180, 180)
        @errors << "Longitude 2 must be between -180 and 180" unless @lon2.between?(-180, 180)
      else
        @errors << "Distance must be greater than zero" unless @distance_km.positive?
      end
      @errors << "Cruise speed must be greater than zero" unless @cruise_speed_kph.positive?
      @errors << "Taxi minutes cannot be negative" if @taxi_minutes.negative?
    end
  end
end
