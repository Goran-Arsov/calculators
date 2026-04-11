# frozen_string_literal: true

module Geography
  class LatitudeLongitudeConverter
    attr_reader :errors

    def initialize(decimal_lat: nil, decimal_lon: nil,
                   lat_deg: nil, lat_min: nil, lat_sec: nil, lat_hemi: "N",
                   lon_deg: nil, lon_min: nil, lon_sec: nil, lon_hemi: "E",
                   mode: "dms_to_decimal")
      @decimal_lat = decimal_lat&.to_f
      @decimal_lon = decimal_lon&.to_f
      @lat_deg = lat_deg&.to_f
      @lat_min = lat_min&.to_f
      @lat_sec = lat_sec&.to_f
      @lat_hemi = (lat_hemi || "N").to_s.upcase
      @lon_deg = lon_deg&.to_f
      @lon_min = lon_min&.to_f
      @lon_sec = lon_sec&.to_f
      @lon_hemi = (lon_hemi || "E").to_s.upcase
      @mode = mode.to_s
      @errors = []
    end

    def call
      if @mode == "decimal_to_dms"
        decimal_to_dms
      else
        dms_to_decimal
      end
    end

    private

    def dms_to_decimal
      validate_dms!
      return { valid: false, errors: @errors } if @errors.any?

      lat_decimal = @lat_deg + @lat_min / 60.0 + @lat_sec / 3600.0
      lat_decimal = -lat_decimal if @lat_hemi == "S"

      lon_decimal = @lon_deg + @lon_min / 60.0 + @lon_sec / 3600.0
      lon_decimal = -lon_decimal if @lon_hemi == "W"

      {
        valid: true,
        decimal_lat: lat_decimal.round(6),
        decimal_lon: lon_decimal.round(6),
        formatted: format_decimal(lat_decimal, lon_decimal)
      }
    end

    def decimal_to_dms
      validate_decimal!
      return { valid: false, errors: @errors } if @errors.any?

      lat_dms = to_dms_parts(@decimal_lat, @decimal_lat.negative? ? "S" : "N")
      lon_dms = to_dms_parts(@decimal_lon, @decimal_lon.negative? ? "W" : "E")

      {
        valid: true,
        lat_deg: lat_dms[:deg],
        lat_min: lat_dms[:min],
        lat_sec: lat_dms[:sec],
        lat_hemi: lat_dms[:hemi],
        lon_deg: lon_dms[:deg],
        lon_min: lon_dms[:min],
        lon_sec: lon_dms[:sec],
        lon_hemi: lon_dms[:hemi],
        formatted: "#{format_dms(lat_dms)}, #{format_dms(lon_dms)}"
      }
    end

    def to_dms_parts(value, hemi)
      abs = value.abs
      deg = abs.floor
      min_full = (abs - deg) * 60
      min = min_full.floor
      sec = ((min_full - min) * 60).round(3)
      { deg: deg, min: min, sec: sec, hemi: hemi }
    end

    def format_dms(parts)
      "#{parts[:deg]}°#{parts[:min]}'#{parts[:sec]}\"#{parts[:hemi]}"
    end

    def format_decimal(lat, lon)
      "#{lat.round(6)}, #{lon.round(6)}"
    end

    def validate_dms!
      @errors << "Latitude degrees must be between 0 and 90" unless @lat_deg&.between?(0, 90)
      @errors << "Latitude minutes must be between 0 and 59" unless @lat_min&.between?(0, 59.999999)
      @errors << "Latitude seconds must be between 0 and 59.999" unless @lat_sec&.between?(0, 59.999999)
      @errors << "Longitude degrees must be between 0 and 180" unless @lon_deg&.between?(0, 180)
      @errors << "Longitude minutes must be between 0 and 59" unless @lon_min&.between?(0, 59.999999)
      @errors << "Longitude seconds must be between 0 and 59.999" unless @lon_sec&.between?(0, 59.999999)
      @errors << "Latitude hemisphere must be N or S" unless %w[N S].include?(@lat_hemi)
      @errors << "Longitude hemisphere must be E or W" unless %w[E W].include?(@lon_hemi)
    end

    def validate_decimal!
      @errors << "Decimal latitude must be between -90 and 90" unless @decimal_lat&.between?(-90, 90)
      @errors << "Decimal longitude must be between -180 and 180" unless @decimal_lon&.between?(-180, 180)
    end
  end
end
