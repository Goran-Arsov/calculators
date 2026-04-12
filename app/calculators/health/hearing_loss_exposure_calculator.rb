module Health
  class HearingLossExposureCalculator
    attr_reader :errors

    # NIOSH Recommended Exposure Limit: 85 dB for 8 hours
    # Each 3 dB increase halves the safe exposure time
    NIOSH_BASE_DB = 85
    NIOSH_BASE_HOURS = 8.0
    NIOSH_EXCHANGE_RATE = 3 # dB doubling rate

    # OSHA Permissible Exposure Limit: 90 dB for 8 hours
    # Each 5 dB increase halves the safe exposure time
    OSHA_BASE_DB = 90
    OSHA_BASE_HOURS = 8.0
    OSHA_EXCHANGE_RATE = 5 # dB doubling rate

    # Common sound levels for reference
    SOUND_REFERENCES = [
      { name: "Whisper", db: 30 },
      { name: "Normal conversation", db: 60 },
      { name: "Vacuum cleaner", db: 70 },
      { name: "City traffic", db: 80 },
      { name: "Lawn mower", db: 85 },
      { name: "Motorcycle", db: 95 },
      { name: "Concert / Nightclub", db: 105 },
      { name: "Chainsaw", db: 110 },
      { name: "Ambulance siren", db: 120 },
      { name: "Fireworks", db: 140 },
      { name: "Gunshot", db: 165 }
    ].freeze

    def initialize(decibel_level:, exposure_hours: nil)
      @decibel_level = decibel_level.to_f
      @exposure_hours = exposure_hours&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      niosh_safe = safe_exposure_time(@decibel_level, NIOSH_BASE_DB, NIOSH_BASE_HOURS, NIOSH_EXCHANGE_RATE)
      osha_safe = safe_exposure_time(@decibel_level, OSHA_BASE_DB, OSHA_BASE_HOURS, OSHA_EXCHANGE_RATE)

      result = {
        valid: true,
        decibel_level: @decibel_level,
        niosh: {
          safe_hours: niosh_safe.round(4),
          safe_formatted: format_duration(niosh_safe),
          standard: "NIOSH REL",
          base_db: NIOSH_BASE_DB,
          base_hours: NIOSH_BASE_HOURS,
          exchange_rate: NIOSH_EXCHANGE_RATE
        },
        osha: {
          safe_hours: osha_safe.round(4),
          safe_formatted: format_duration(osha_safe),
          standard: "OSHA PEL",
          base_db: OSHA_BASE_DB,
          base_hours: OSHA_BASE_HOURS,
          exchange_rate: OSHA_EXCHANGE_RATE
        },
        risk_level: risk_level(@decibel_level),
        sound_references: SOUND_REFERENCES
      }

      if @exposure_hours
        niosh_dose = (@exposure_hours / niosh_safe * 100).round(1)
        osha_dose = (@exposure_hours / osha_safe * 100).round(1)
        result[:exposure_hours] = @exposure_hours
        result[:niosh][:dose_percent] = niosh_dose
        result[:niosh][:over_limit] = niosh_dose > 100
        result[:osha][:dose_percent] = osha_dose
        result[:osha][:over_limit] = osha_dose > 100
      end

      result
    end

    private

    def safe_exposure_time(db, base_db, base_hours, exchange_rate)
      return Float::INFINITY if db < base_db

      base_hours / (2.0**((db - base_db).to_f / exchange_rate))
    end

    def format_duration(hours)
      return "Unlimited (below threshold)" if hours == Float::INFINITY
      return "< 1 second" if hours < 1.0 / 3600

      if hours >= 1
        h = hours.floor
        m = ((hours - h) * 60).round
        if m == 60
          h += 1
          m = 0
        end
        m > 0 ? "#{h}h #{m}m" : "#{h}h"
      elsif hours * 60 >= 1
        m = (hours * 60).floor
        s = ((hours * 60 - m) * 60).round
        s > 0 ? "#{m}m #{s}s" : "#{m}m"
      else
        s = (hours * 3600).round
        "#{s}s"
      end
    end

    def risk_level(db)
      if db < 70
        "Safe - No hearing damage risk"
      elsif db < 85
        "Low - Prolonged exposure may cause gradual hearing loss"
      elsif db < 100
        "Moderate - Hearing protection recommended"
      elsif db < 120
        "High - Hearing protection required"
      else
        "Extreme - Immediate hearing damage possible"
      end
    end

    def validate!
      @errors << "Decibel level must be positive" unless @decibel_level > 0
      @errors << "Decibel level seems unrealistic (max 200 dB)" if @decibel_level > 200
      if @exposure_hours && @exposure_hours < 0
        @errors << "Exposure hours must be zero or positive"
      end
    end
  end
end
