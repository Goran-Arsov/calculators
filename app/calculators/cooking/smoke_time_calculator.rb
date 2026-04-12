# frozen_string_literal: true

module Cooking
  class SmokeTimeCalculator
    attr_reader :errors

    # Smoking data: { meat_type => { smoker_temp_range => minutes_per_lb, target_internal_temp_f } }
    SMOKE_DATA = {
      "beef_brisket" => { target_temp_f: 200, minutes_per_lb: { low: 90, standard: 75, hot: 60 } },
      "pork_butt" => { target_temp_f: 200, minutes_per_lb: { low: 90, standard: 75, hot: 60 } },
      "pork_ribs" => { target_temp_f: 190, minutes_per_lb: { low: 75, standard: 60, hot: 45 } },
      "whole_chicken" => { target_temp_f: 165, minutes_per_lb: { low: 45, standard: 30, hot: 25 } },
      "turkey_breast" => { target_temp_f: 165, minutes_per_lb: { low: 40, standard: 35, hot: 25 } },
      "whole_turkey" => { target_temp_f: 165, minutes_per_lb: { low: 35, standard: 30, hot: 20 } },
      "salmon" => { target_temp_f: 145, minutes_per_lb: { low: 45, standard: 35, hot: 25 } },
      "pork_loin" => { target_temp_f: 145, minutes_per_lb: { low: 50, standard: 40, hot: 30 } },
      "lamb_shoulder" => { target_temp_f: 190, minutes_per_lb: { low: 75, standard: 60, hot: 45 } },
      "beef_chuck_roast" => { target_temp_f: 200, minutes_per_lb: { low: 75, standard: 60, hot: 50 } },
      "sausage" => { target_temp_f: 165, minutes_per_lb: { low: 50, standard: 40, hot: 30 } }
    }.freeze

    # Smoker temp ranges (F)
    TEMP_RANGES = {
      "low" => { min: 180, max: 224, label: "Low & Slow (200-225 F)" },
      "standard" => { min: 225, max: 274, label: "Standard (225-275 F)" },
      "hot" => { min: 275, max: 400, label: "Hot & Fast (275-350 F)" }
    }.freeze

    def initialize(meat_type:, weight_lbs:, smoker_temp:)
      @meat_type = meat_type.to_s.strip
      @weight_lbs = weight_lbs.to_f
      @smoker_temp = smoker_temp.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      temp_range = determine_temp_range
      meat_data = SMOKE_DATA[@meat_type]
      base_minutes_per_lb = meat_data[:minutes_per_lb][temp_range.to_sym]

      # Fine-tune based on exact temp within range
      range_data = TEMP_RANGES[temp_range]
      range_midpoint = (range_data[:min] + range_data[:max]) / 2.0
      temp_adjustment = 1.0 + (range_midpoint - @smoker_temp) * 0.003
      adjusted_minutes_per_lb = (base_minutes_per_lb * temp_adjustment).round(1)

      total_minutes = (adjusted_minutes_per_lb * @weight_lbs).round(0)
      hours = total_minutes / 60
      minutes = total_minutes % 60

      # Add estimated stall time for large cuts
      stall_minutes = stall_time_estimate

      {
        valid: true,
        meat_type: @meat_type,
        weight_lbs: @weight_lbs,
        smoker_temp: @smoker_temp,
        temp_range: temp_range,
        temp_range_label: TEMP_RANGES[temp_range][:label],
        target_internal_temp_f: meat_data[:target_temp_f],
        minutes_per_lb: adjusted_minutes_per_lb,
        total_minutes: total_minutes,
        hours: hours,
        minutes: minutes,
        stall_minutes: stall_minutes,
        total_with_stall: total_minutes + stall_minutes,
        rest_time_minutes: rest_time_estimate
      }
    end

    def self.available_meats
      SMOKE_DATA.keys
    end

    private

    def validate!
      @errors << "Weight must be positive" unless @weight_lbs > 0
      @errors << "Smoker temperature must be between 180 and 400 F" unless @smoker_temp >= 180 && @smoker_temp <= 400
      @errors << "Unknown meat type: #{@meat_type}" unless SMOKE_DATA.key?(@meat_type)
    end

    def determine_temp_range
      TEMP_RANGES.each do |key, range|
        return key if @smoker_temp >= range[:min] && @smoker_temp <= range[:max]
      end
      # If outside defined ranges, pick closest
      @smoker_temp < 200 ? "low" : "hot"
    end

    def stall_time_estimate
      # Large cuts like brisket and pork butt experience a "stall" around 150-170 F
      stall_cuts = %w[beef_brisket pork_butt beef_chuck_roast lamb_shoulder]
      return 0 unless stall_cuts.include?(@meat_type)
      return 0 if @weight_lbs < 3

      (@weight_lbs * 8).round(0).clamp(30, 120)
    end

    def rest_time_estimate
      case @meat_type
      when "beef_brisket", "pork_butt", "lamb_shoulder", "beef_chuck_roast"
        @weight_lbs >= 8 ? 60 : 30
      when "whole_turkey"
        30
      when "pork_ribs"
        15
      else
        15
      end
    end
  end
end
