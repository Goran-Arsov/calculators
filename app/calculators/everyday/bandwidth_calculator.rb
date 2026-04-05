# frozen_string_literal: true

module Everyday
  class BandwidthCalculator
    attr_reader :errors

    SIZE_UNITS = {
      "B"  => 1,
      "KB" => 1_024,
      "MB" => 1_048_576,
      "GB" => 1_073_741_824,
      "TB" => 1_099_511_627_776
    }.freeze

    SPEED_UNITS = {
      "bps"  => 1,
      "Kbps" => 1_000,
      "Mbps" => 1_000_000,
      "Gbps" => 1_000_000_000
    }.freeze

    def initialize(file_size:, file_unit:, speed:, speed_unit:)
      @file_size = file_size.to_f
      @file_unit = file_unit.to_s.strip
      @speed = speed.to_f
      @speed_unit = speed_unit.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      file_bytes = @file_size * SIZE_UNITS[@file_unit]
      file_bits = file_bytes * 8
      speed_bps = @speed * SPEED_UNITS[@speed_unit]

      download_seconds = file_bits / speed_bps
      download_time = humanize_time(download_seconds)

      # Also calculate speed needed to download in common times
      speed_for_1_min = speed_bps > 0 ? file_bits / 60.0 : 0
      speed_for_10_min = speed_bps > 0 ? file_bits / 600.0 : 0
      speed_for_1_hour = speed_bps > 0 ? file_bits / 3600.0 : 0

      {
        download_seconds: download_seconds.round(2),
        download_time: download_time,
        file_size_bytes: file_bytes.round(0),
        file_size_mb: (file_bytes / 1_048_576.0).round(2),
        speed_bps: speed_bps.round(0),
        speed_mbps: (speed_bps / 1_000_000.0).round(2),
        speed_for_1_min_mbps: (speed_for_1_min / 1_000_000.0).round(2),
        speed_for_10_min_mbps: (speed_for_10_min / 1_000_000.0).round(2),
        speed_for_1_hour_mbps: (speed_for_1_hour / 1_000_000.0).round(4)
      }
    end

    private

    def humanize_time(seconds)
      return "Less than 1 second" if seconds < 1

      parts = []
      if seconds >= 3600
        hours = (seconds / 3600).floor
        parts << "#{hours}h"
        seconds %= 3600
      end
      if seconds >= 60
        minutes = (seconds / 60).floor
        parts << "#{minutes}m"
        seconds %= 60
      end
      if seconds >= 1
        parts << "#{seconds.round(1)}s"
      end

      parts.join(" ")
    end

    def validate!
      @errors << "File size must be greater than zero" unless @file_size.positive?
      @errors << "Unknown file size unit: #{@file_unit}. Valid: #{SIZE_UNITS.keys.join(', ')}" unless SIZE_UNITS.key?(@file_unit)
      @errors << "Speed must be greater than zero" unless @speed.positive?
      @errors << "Unknown speed unit: #{@speed_unit}. Valid: #{SPEED_UNITS.keys.join(', ')}" unless SPEED_UNITS.key?(@speed_unit)
    end
  end
end
