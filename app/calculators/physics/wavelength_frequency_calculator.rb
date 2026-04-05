module Physics
  class WavelengthFrequencyCalculator
    SPEED_OF_LIGHT = 299_792_458.0 # m/s
    PLANCK_CONSTANT = 6.62607015e-34 # J·s

    attr_reader :errors

    def initialize(wavelength: nil, frequency: nil, energy: nil)
      @wavelength = wavelength&.to_f
      @frequency = frequency&.to_f
      @energy = energy&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @wavelength && !@frequency && !@energy
        f = SPEED_OF_LIGHT / @wavelength
        e = PLANCK_CONSTANT * f
        t = 1.0 / f
        { valid: true, wavelength: round_sig(@wavelength), frequency: round_sig(f), energy: round_sig(e), period: round_sig(t), solved_for: :frequency }
      elsif @frequency && !@wavelength && !@energy
        l = SPEED_OF_LIGHT / @frequency
        e = PLANCK_CONSTANT * @frequency
        t = 1.0 / @frequency
        { valid: true, wavelength: round_sig(l), frequency: round_sig(@frequency), energy: round_sig(e), period: round_sig(t), solved_for: :wavelength }
      else
        f = @energy / PLANCK_CONSTANT
        l = SPEED_OF_LIGHT / f
        t = 1.0 / f
        { valid: true, wavelength: round_sig(l), frequency: round_sig(f), energy: round_sig(@energy), period: round_sig(t), solved_for: :energy }
      end
    end

    private

    SIGNIFICANT_DIGITS = 4

    def round_sig(value, digits = SIGNIFICANT_DIGITS)
      return 0.0 if value.zero?
      d = (Math.log10(value.abs)).floor + 1
      value.round(digits - d)
    end

    def validate!
      provided = { wavelength: @wavelength, frequency: @frequency, energy: @energy }.compact
      if provided.empty?
        @errors << "Provide at least one value"
        return
      end

      @errors << "Wavelength must be positive" if @wavelength && @wavelength <= 0
      @errors << "Frequency must be positive" if @frequency && @frequency <= 0
      @errors << "Energy must be positive" if @energy && @energy <= 0
    end
  end
end
