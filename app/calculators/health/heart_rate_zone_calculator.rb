module Health
  class HeartRateZoneCalculator
    attr_reader :errors

    # Karvonen method zone percentages (of heart rate reserve)
    ZONES = {
      zone_1: { name: "Warm Up / Recovery", min_pct: 50, max_pct: 60 },
      zone_2: { name: "Fat Burn", min_pct: 60, max_pct: 70 },
      zone_3: { name: "Aerobic / Cardio", min_pct: 70, max_pct: 80 },
      zone_4: { name: "Anaerobic / Threshold", min_pct: 80, max_pct: 90 },
      zone_5: { name: "VO2 Max / Peak", min_pct: 90, max_pct: 100 }
    }.freeze

    def initialize(age:, resting_hr: 70)
      @age = age.to_i
      @resting_hr = resting_hr.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      max_hr = calculate_max_hr
      hrr = max_hr - @resting_hr # Heart Rate Reserve

      zones = ZONES.map do |key, zone|
        min_bpm = (@resting_hr + hrr * zone[:min_pct] / 100.0).round(0)
        max_bpm = (@resting_hr + hrr * zone[:max_pct] / 100.0).round(0)
        {
          key: key,
          name: zone[:name],
          min_pct: zone[:min_pct],
          max_pct: zone[:max_pct],
          min_bpm: min_bpm,
          max_bpm: max_bpm
        }
      end

      {
        valid: true,
        max_hr: max_hr,
        resting_hr: @resting_hr,
        heart_rate_reserve: hrr,
        zones: zones
      }
    end

    private

    # Tanaka formula: HRmax = 208 - 0.7 * age
    # More accurate than the classic 220 - age for general population
    def calculate_max_hr
      (208 - 0.7 * @age).round(0)
    end

    def validate!
      @errors << "Age must be positive" unless @age > 0
      @errors << "Age must be realistic (1-120)" unless @age.between?(1, 120)
      @errors << "Resting heart rate must be positive" unless @resting_hr > 0
      @errors << "Resting heart rate must be realistic (30-120 bpm)" unless @resting_hr.between?(30, 120)
    end
  end
end
