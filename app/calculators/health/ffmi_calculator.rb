module Health
  class FfmiCalculator
    attr_reader :errors

    def initialize(weight_kg:, height_cm:, body_fat_percent:)
      @weight_kg = weight_kg.to_f
      @height_cm = height_cm.to_f
      @body_fat_percent = body_fat_percent.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      height_m = @height_cm / 100.0
      lean_mass_kg = @weight_kg * (1 - @body_fat_percent / 100.0)
      fat_mass_kg = @weight_kg - lean_mass_kg
      ffmi = lean_mass_kg / (height_m**2)
      adjusted_ffmi = ffmi + 6.1 * (1.8 - height_m)
      category = categorize(adjusted_ffmi)

      {
        valid: true,
        lean_mass_kg: lean_mass_kg.round(2),
        fat_mass_kg: fat_mass_kg.round(2),
        ffmi: ffmi.round(2),
        adjusted_ffmi: adjusted_ffmi.round(2),
        category: category
      }
    end

    private

    def categorize(adjusted_ffmi)
      case adjusted_ffmi
      when -Float::INFINITY...18 then "Below Average"
      when 18...20 then "Average"
      when 20...22 then "Above Average"
      when 22...25 then "Excellent"
      else "Superior / Elite"
      end
    end

    def validate!
      @errors << "Weight must be positive" unless @weight_kg > 0
      @errors << "Height must be positive" unless @height_cm > 0
      @errors << "Body fat percent must be between 0 and 70" unless @body_fat_percent >= 0 && @body_fat_percent <= 70
      @errors << "Weight cannot exceed 300 kg" if @weight_kg > 300
      @errors << "Height cannot exceed 250 cm" if @height_cm > 250
    end
  end
end
