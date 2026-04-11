# frozen_string_literal: true

module Geography
  class GeohashConverter
    attr_reader :errors

    BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz".freeze
    DEFAULT_PRECISION = 9
    MIN_PRECISION = 1
    MAX_PRECISION = 12

    def initialize(mode: "encode", lat: nil, lon: nil, precision: DEFAULT_PRECISION, geohash: nil)
      @mode = mode.to_s
      @lat = lat&.to_f
      @lon = lon&.to_f
      @precision = precision.to_i
      @geohash = geohash.to_s.downcase.strip
      @errors = []
    end

    def call
      if @mode == "decode"
        decode
      else
        encode
      end
    end

    private

    def encode
      validate_encode!
      return { valid: false, errors: @errors } if @errors.any?

      lat_range = [ -90.0, 90.0 ]
      lon_range = [ -180.0, 180.0 ]
      bits = []
      even = true

      while bits.length < @precision * 5
        if even
          mid = (lon_range[0] + lon_range[1]) / 2.0
          if @lon >= mid
            bits << 1
            lon_range[0] = mid
          else
            bits << 0
            lon_range[1] = mid
          end
        else
          mid = (lat_range[0] + lat_range[1]) / 2.0
          if @lat >= mid
            bits << 1
            lat_range[0] = mid
          else
            bits << 0
            lat_range[1] = mid
          end
        end
        even = !even
      end

      hash = bits.each_slice(5).map { |chunk| BASE32[chunk.inject(0) { |acc, b| (acc << 1) | b }] }.join

      {
        valid: true,
        geohash: hash,
        precision: @precision,
        input_lat: @lat,
        input_lon: @lon
      }
    end

    def decode
      validate_decode!
      return { valid: false, errors: @errors } if @errors.any?

      lat_range = [ -90.0, 90.0 ]
      lon_range = [ -180.0, 180.0 ]
      even = true

      @geohash.each_char do |char|
        index = BASE32.index(char)
        if index.nil?
          return { valid: false, errors: [ "Invalid geohash character: '#{char}'" ] }
        end
        5.times do |i|
          bit = (index >> (4 - i)) & 1
          if even
            mid = (lon_range[0] + lon_range[1]) / 2.0
            if bit == 1
              lon_range[0] = mid
            else
              lon_range[1] = mid
            end
          else
            mid = (lat_range[0] + lat_range[1]) / 2.0
            if bit == 1
              lat_range[0] = mid
            else
              lat_range[1] = mid
            end
          end
          even = !even
        end
      end

      center_lat = (lat_range[0] + lat_range[1]) / 2.0
      center_lon = (lon_range[0] + lon_range[1]) / 2.0
      lat_error = (lat_range[1] - lat_range[0]) / 2.0
      lon_error = (lon_range[1] - lon_range[0]) / 2.0

      {
        valid: true,
        decoded_lat: center_lat.round(8),
        decoded_lon: center_lon.round(8),
        lat_error: lat_error.round(8),
        lon_error: lon_error.round(8),
        bbox_sw: [ lat_range[0].round(8), lon_range[0].round(8) ],
        bbox_ne: [ lat_range[1].round(8), lon_range[1].round(8) ],
        precision: @geohash.length
      }
    end

    def validate_encode!
      @errors << "Latitude must be between -90 and 90" unless @lat&.between?(-90, 90)
      @errors << "Longitude must be between -180 and 180" unless @lon&.between?(-180, 180)
      unless @precision.between?(MIN_PRECISION, MAX_PRECISION)
        @errors << "Precision must be between #{MIN_PRECISION} and #{MAX_PRECISION}"
      end
    end

    def validate_decode!
      @errors << "Geohash cannot be empty" if @geohash.empty?
      if @geohash.length > MAX_PRECISION
        @errors << "Geohash too long (max #{MAX_PRECISION} characters)"
      end
      @geohash.each_char do |char|
        unless BASE32.include?(char)
          @errors << "Invalid geohash character: '#{char}'"
          break
        end
      end
    end
  end
end
