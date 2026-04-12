module Health
  class CyclingFtpCalculator
    attr_reader :errors

    # Coggan Power Zones based on FTP percentage
    ZONES = {
      zone_1: { name: "Active Recovery", min_pct: 0, max_pct: 55, description: "Very easy spinning for recovery" },
      zone_2: { name: "Endurance", min_pct: 56, max_pct: 75, description: "All-day pace for building aerobic base" },
      zone_3: { name: "Tempo", min_pct: 76, max_pct: 90, description: "Moderate effort, can sustain 1-3 hours" },
      zone_4: { name: "Lactate Threshold", min_pct: 91, max_pct: 105, description: "Sustainable for 20-60 minutes" },
      zone_5: { name: "VO2max", min_pct: 106, max_pct: 120, description: "Hard intervals, 3-8 minute efforts" },
      zone_6: { name: "Anaerobic Capacity", min_pct: 121, max_pct: 150, description: "Very hard, 30 seconds to 3 minutes" },
      zone_7: { name: "Neuromuscular Power", min_pct: 151, max_pct: nil, description: "Maximum sprints, under 30 seconds" }
    }.freeze

    # FTP estimation methods
    ESTIMATION_METHODS = %w[direct twenty_minute eight_minute ramp].freeze

    def initialize(mode: "direct", ftp: nil, test_power: nil, weight: nil, weight_unit: "kg")
      @mode = mode.to_s
      @ftp = ftp&.to_f
      @test_power = test_power&.to_f
      @weight = weight&.to_f
      @weight_unit = weight_unit.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      estimated_ftp = calculate_ftp

      zones = ZONES.map do |key, zone|
        min_watts = (estimated_ftp * zone[:min_pct] / 100.0).round(0)
        max_watts = zone[:max_pct] ? (estimated_ftp * zone[:max_pct] / 100.0).round(0) : nil
        {
          key: key,
          name: zone[:name],
          description: zone[:description],
          min_pct: zone[:min_pct],
          max_pct: zone[:max_pct],
          min_watts: min_watts,
          max_watts: max_watts,
          range_display: max_watts ? "#{min_watts} - #{max_watts} W" : "#{min_watts}+ W"
        }
      end

      result = {
        valid: true,
        ftp: estimated_ftp.round(0).to_i,
        estimation_method: @mode,
        zones: zones
      }

      if @weight && @weight > 0
        weight_kg = @weight_unit == "lbs" ? @weight * 0.453592 : @weight
        watts_per_kg = estimated_ftp / weight_kg
        result[:weight_kg] = weight_kg.round(1)
        result[:watts_per_kg] = watts_per_kg.round(2)
        result[:rider_category] = rider_category(watts_per_kg)
      end

      result
    end

    private

    def calculate_ftp
      case @mode
      when "direct"
        @ftp
      when "twenty_minute"
        # 20-minute test: FTP = 95% of 20-min average power
        @test_power * 0.95
      when "eight_minute"
        # 8-minute test: FTP = 90% of 8-min average power
        @test_power * 0.90
      when "ramp"
        # Ramp test: FTP = 75% of highest 1-minute power
        @test_power * 0.75
      end
    end

    def rider_category(wpk)
      if wpk >= 5.5
        "World Tour Pro"
      elsif wpk >= 4.6
        "Cat 1 / Elite"
      elsif wpk >= 4.0
        "Cat 2 / Very Strong"
      elsif wpk >= 3.4
        "Cat 3 / Strong"
      elsif wpk >= 2.8
        "Cat 4 / Moderate"
      elsif wpk >= 2.0
        "Cat 5 / Recreational"
      else
        "Beginner"
      end
    end

    def validate!
      unless ESTIMATION_METHODS.include?(@mode)
        @errors << "Mode must be direct, twenty_minute, eight_minute, or ramp"
        return
      end

      if @mode == "direct"
        if @ftp.nil? || @ftp <= 0
          @errors << "FTP must be positive"
        elsif @ftp > 600
          @errors << "FTP seems unrealistically high (max 600W)"
        end
      else
        if @test_power.nil? || @test_power <= 0
          @errors << "Test power must be positive"
        elsif @test_power > 800
          @errors << "Test power seems unrealistically high (max 800W)"
        end
      end

      if @weight && @weight < 0
        @errors << "Weight must be positive"
      end
      if @weight_unit && !%w[kg lbs].include?(@weight_unit)
        @errors << "Weight unit must be kg or lbs"
      end
    end
  end
end
