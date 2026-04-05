# frozen_string_literal: true

module Everyday
  class MovingCostCalculator
    attr_reader :errors

    HOME_SIZE_MULTIPLIERS = {
      "studio"  => { base_low: 400,  base_high: 800,  weight_lbs: 2000 },
      "1bed"    => { base_low: 500,  base_high: 1000, weight_lbs: 3500 },
      "2bed"    => { base_low: 800,  base_high: 1500, weight_lbs: 5000 },
      "3bed"    => { base_low: 1200, base_high: 2200, weight_lbs: 7500 },
      "4bed"    => { base_low: 1500, base_high: 3000, weight_lbs: 10000 },
      "5bed"    => { base_low: 2000, base_high: 4000, weight_lbs: 12000 }
    }.freeze

    EXTRAS = {
      "packing"   => { low: 200,  high: 600 },
      "piano"     => { low: 200,  high: 500 },
      "storage"   => { low: 100,  high: 300 },
      "insurance" => { low: 50,   high: 200 },
      "stairs"    => { low: 75,   high: 250 }
    }.freeze

    LONG_DISTANCE_RATE_PER_MILE = 0.50  # per pound-mile simplified to per mile with weight factor

    def initialize(distance_miles:, home_size:, extras: "")
      @distance = distance_miles.to_f
      @home_size = home_size.to_s.downcase.strip
      @extras_str = extras.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      size_data = HOME_SIZE_MULTIPLIERS[@home_size]
      selected_extras = parse_extras

      if @distance <= 100
        # Local move: flat rate based on home size
        base_low = size_data[:base_low]
        base_high = size_data[:base_high]
      else
        # Long distance: base + distance factor
        distance_factor = @distance * LONG_DISTANCE_RATE_PER_MILE * (size_data[:weight_lbs] / 5000.0)
        base_low = size_data[:base_low] + distance_factor * 0.8
        base_high = size_data[:base_high] + distance_factor * 1.2
      end

      extras_low = 0
      extras_high = 0
      extras_breakdown = []

      selected_extras.each do |extra_key|
        if EXTRAS.key?(extra_key)
          extras_low += EXTRAS[extra_key][:low]
          extras_high += EXTRAS[extra_key][:high]
          extras_breakdown << { name: extra_key, low: EXTRAS[extra_key][:low], high: EXTRAS[extra_key][:high] }
        end
      end

      total_low = base_low + extras_low
      total_high = base_high + extras_high

      {
        valid: true,
        estimate_low: total_low.round(0),
        estimate_high: total_high.round(0),
        base_low: base_low.round(0),
        base_high: base_high.round(0),
        extras_low: extras_low,
        extras_high: extras_high,
        extras_breakdown: extras_breakdown,
        distance: @distance,
        home_size: @home_size,
        is_long_distance: @distance > 100
      }
    end

    private

    def parse_extras
      @extras_str.split(",").map(&:strip).reject(&:empty?)
    end

    def validate!
      @errors << "Distance must be greater than zero" unless @distance.positive?
      @errors << "Unknown home size: #{@home_size}. Valid: #{HOME_SIZE_MULTIPLIERS.keys.join(', ')}" unless HOME_SIZE_MULTIPLIERS.key?(@home_size)
    end
  end
end
