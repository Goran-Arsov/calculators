# frozen_string_literal: true

module Health
  class LeanBodyMassCalculator
    attr_reader :errors

    def initialize(weight:, body_fat_percentage: nil, gender: nil, height: nil, unit_system: "metric")
      @weight = weight.to_f
      @body_fat_percentage = body_fat_percentage.nil? || body_fat_percentage.to_s.strip.empty? ? nil : body_fat_percentage.to_f
      @gender = gender&.to_s
      @height = height.nil? || height.to_s.strip.empty? ? nil : height.to_f
      @unit_system = unit_system.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      results = if @body_fat_percentage
        calculate_from_body_fat
      else
        calculate_from_measurements
      end

      results
    end

    private

    # Direct calculation from body fat percentage
    def calculate_from_body_fat
      fat_mass = @weight * @body_fat_percentage / 100.0
      lean_mass = @weight - fat_mass

      {
        valid: true,
        method: "body_fat_percentage",
        lean_body_mass: lean_mass.round(1),
        fat_mass: fat_mass.round(1),
        body_fat_percentage: @body_fat_percentage.round(1),
        lean_percentage: (100.0 - @body_fat_percentage).round(1),
        unit: @unit_system == "imperial" ? "lbs" : "kg"
      }
    end

    # Boer formula (1984) — considered most accurate estimation formula
    # Male: LBM = 0.407 * weight(kg) + 0.267 * height(cm) - 19.2
    # Female: LBM = 0.252 * weight(kg) + 0.473 * height(cm) - 48.3
    def calculate_from_measurements
      weight_kg = @unit_system == "imperial" ? @weight * 0.453592 : @weight
      height_cm = @unit_system == "imperial" ? @height * 2.54 : @height

      boer_lbm = if @gender == "male"
        0.407 * weight_kg + 0.267 * height_cm - 19.2
      else
        0.252 * weight_kg + 0.473 * height_cm - 48.3
      end

      # James formula (1976) for comparison
      # Male: LBM = 1.1 * weight(kg) - 128 * (weight(kg) / height(cm))^2
      # Female: LBM = 1.07 * weight(kg) - 148 * (weight(kg) / height(cm))^2
      james_lbm = if @gender == "male"
        1.1 * weight_kg - 128.0 * (weight_kg / height_cm)**2
      else
        1.07 * weight_kg - 148.0 * (weight_kg / height_cm)**2
      end

      # Hume formula (1966)
      # Male: LBM = 0.32810 * weight(kg) + 0.33929 * height(cm) - 29.5336
      # Female: LBM = 0.29569 * weight(kg) + 0.41813 * height(cm) - 43.2933
      hume_lbm = if @gender == "male"
        0.32810 * weight_kg + 0.33929 * height_cm - 29.5336
      else
        0.29569 * weight_kg + 0.41813 * height_cm - 43.2933
      end

      # Use Boer as primary result
      lean_mass = boer_lbm
      fat_mass = weight_kg - lean_mass
      bf_percentage = (fat_mass / weight_kg * 100.0)

      # Convert back to display units if imperial
      display_factor = @unit_system == "imperial" ? 2.20462 : 1.0

      {
        valid: true,
        method: "formula",
        lean_body_mass: (lean_mass * display_factor).round(1),
        fat_mass: (fat_mass * display_factor).round(1),
        body_fat_percentage: bf_percentage.round(1),
        lean_percentage: (100.0 - bf_percentage).round(1),
        boer_lbm: (boer_lbm * display_factor).round(1),
        james_lbm: (james_lbm * display_factor).round(1),
        hume_lbm: (hume_lbm * display_factor).round(1),
        unit: @unit_system == "imperial" ? "lbs" : "kg"
      }
    end

    def validate!
      @errors << "Weight must be positive" unless @weight > 0
      @errors << "Invalid unit system" unless %w[metric imperial].include?(@unit_system)

      if @body_fat_percentage
        @errors << "Body fat percentage must be between 1 and 70" unless @body_fat_percentage.between?(1, 70)
      else
        @errors << "Gender is required when using formula method" unless %w[male female].include?(@gender)
        @errors << "Height is required when using formula method" if @height.nil? || @height <= 0
      end
    end
  end
end
