# frozen_string_literal: true

module Photography
  class GoldenHourCalculator
    attr_reader :errors

    # Solar elevation angles (degrees) for each period
    GOLDEN_HOUR_UPPER = 6.0   # Sun above horizon
    GOLDEN_HOUR_LOWER = -4.0  # Sun around horizon (includes civil twilight start)
    BLUE_HOUR_UPPER = -4.0
    BLUE_HOUR_LOWER = -6.0
    SUNRISE_SUNSET_ANGLE = -0.833 # Accounts for atmospheric refraction

    DEGREES_TO_RADIANS = Math::PI / 180.0
    RADIANS_TO_DEGREES = 180.0 / Math::PI

    def initialize(latitude:, longitude:, date:, timezone_offset: 0)
      @latitude = latitude.to_f
      @longitude = longitude.to_f
      @date = date.is_a?(Date) ? date : Date.parse(date.to_s)
      @timezone_offset = timezone_offset.to_f  # hours from UTC
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      sunrise = time_for_angle(SUNRISE_SUNSET_ANGLE, :rise)
      sunset = time_for_angle(SUNRISE_SUNSET_ANGLE, :set)

      morning_golden_start = time_for_angle(GOLDEN_HOUR_LOWER, :rise)
      morning_golden_end = time_for_angle(GOLDEN_HOUR_UPPER, :rise)
      evening_golden_start = time_for_angle(GOLDEN_HOUR_UPPER, :set)
      evening_golden_end = time_for_angle(GOLDEN_HOUR_LOWER, :set)

      morning_blue_start = time_for_angle(BLUE_HOUR_LOWER, :rise)
      morning_blue_end = time_for_angle(BLUE_HOUR_UPPER, :rise)
      evening_blue_start = time_for_angle(BLUE_HOUR_UPPER, :set)
      evening_blue_end = time_for_angle(BLUE_HOUR_LOWER, :set)

      solar_noon = calculate_solar_noon
      day_length = sunset && sunrise ? (sunset - sunrise) : nil

      {
        valid: true,
        sunrise: format_time(sunrise),
        sunset: format_time(sunset),
        solar_noon: format_time(solar_noon),
        day_length: day_length ? format_duration(day_length) : "N/A",
        morning_golden_hour: {
          start: format_time(morning_golden_start),
          end: format_time(morning_golden_end)
        },
        evening_golden_hour: {
          start: format_time(evening_golden_start),
          end: format_time(evening_golden_end)
        },
        morning_blue_hour: {
          start: format_time(morning_blue_start),
          end: format_time(morning_blue_end)
        },
        evening_blue_hour: {
          start: format_time(evening_blue_start),
          end: format_time(evening_blue_end)
        }
      }
    end

    private

    # Simplified solar position algorithm based on NOAA equations
    def time_for_angle(target_angle, rise_or_set)
      day_of_year = @date.yday
      lat_rad = @latitude * DEGREES_TO_RADIANS

      # Solar declination (radians)
      declination = 23.45 * Math.sin((360.0 / 365.0 * (day_of_year - 81)) * DEGREES_TO_RADIANS) * DEGREES_TO_RADIANS

      # Hour angle for the target elevation
      cos_hour_angle = (Math.sin(target_angle * DEGREES_TO_RADIANS) -
                        Math.sin(lat_rad) * Math.sin(declination)) /
                       (Math.cos(lat_rad) * Math.cos(declination))

      # Sun never reaches this angle (polar day/night)
      return nil if cos_hour_angle.abs > 1.0

      hour_angle = Math.acos(cos_hour_angle) * RADIANS_TO_DEGREES

      # Equation of time (minutes) — approximation
      b = (360.0 / 365.0 * (day_of_year - 81)) * DEGREES_TO_RADIANS
      eot = 9.87 * Math.sin(2 * b) - 7.53 * Math.cos(b) - 1.5 * Math.sin(b)

      # Solar noon in hours (UTC)
      solar_noon_utc = 12.0 - (@longitude / 15.0) - (eot / 60.0)

      if rise_or_set == :rise
        solar_noon_utc - (hour_angle / 15.0) + @timezone_offset
      else
        solar_noon_utc + (hour_angle / 15.0) + @timezone_offset
      end
    end

    def calculate_solar_noon
      day_of_year = @date.yday
      b = (360.0 / 365.0 * (day_of_year - 81)) * DEGREES_TO_RADIANS
      eot = 9.87 * Math.sin(2 * b) - 7.53 * Math.cos(b) - 1.5 * Math.sin(b)
      12.0 - (@longitude / 15.0) - (eot / 60.0) + @timezone_offset
    end

    def format_time(decimal_hours)
      return "N/A" if decimal_hours.nil?

      # Normalize to 0-24 range
      decimal_hours = decimal_hours % 24
      hours = decimal_hours.to_i
      minutes = ((decimal_hours - hours) * 60).round

      if minutes == 60
        hours += 1
        minutes = 0
      end

      hours = hours % 24
      format("%<h>02d:%<m>02d", h: hours, m: minutes)
    end

    def format_duration(decimal_hours)
      hours = decimal_hours.to_i
      minutes = ((decimal_hours - hours) * 60).round
      format("%<h>dh %<m>02dm", h: hours, m: minutes)
    end

    def validate!
      @errors << "Latitude must be between -90 and 90" unless @latitude.between?(-90, 90)
      @errors << "Longitude must be between -180 and 180" unless @longitude.between?(-180, 180)
      @errors << "Date is required" if @date.nil?
      @errors << "Timezone offset must be between -12 and 14" unless @timezone_offset.between?(-12, 14)
    end
  end
end
