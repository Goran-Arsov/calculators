module Physics
  class DecibelCalculator
    attr_reader :errors

    def initialize(mode:, value:)
      @mode = mode.to_s
      @value = value.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = case @mode
      when "power_to_db"
                 db = 10 * ::Math.log10(@value)
                 { db: db.round(4), ratio: @value, mode_label: "Power Ratio to dB" }
      when "db_to_power"
                 ratio = 10**(@value / 10.0)
                 { db: @value, ratio: ratio.round(6), mode_label: "dB to Power Ratio" }
      when "voltage_to_db"
                 db = 20 * ::Math.log10(@value)
                 { db: db.round(4), ratio: @value, mode_label: "Voltage Ratio to dB" }
      when "db_to_voltage"
                 ratio = 10**(@value / 20.0)
                 { db: @value, ratio: ratio.round(6), mode_label: "dB to Voltage Ratio" }
      end

      result.merge(valid: true)
    end

    private

    def validate!
      valid_modes = %w[power_to_db db_to_power voltage_to_db db_to_voltage]
      unless valid_modes.include?(@mode)
        @errors << "Unknown mode: #{@mode}"
        return
      end

      if @mode.end_with?("_to_db") && @value <= 0
        @errors << "Ratio must be positive"
      end
    end
  end
end
