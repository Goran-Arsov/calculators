# frozen_string_literal: true

module Health
  class IdealWeightCalculator
    attr_reader :errors

    # Height in inches for all formulas (imperial-based formulas)
    # Devine (1974), Robinson (1983), Miller (1983), Hamwi (1964)
    BASE_HEIGHT_INCHES = 60 # 5 feet

    def initialize(height:, gender:, frame_size: "medium", unit_system: "metric")
      @height = height.to_f
      @gender = gender.to_s
      @frame_size = frame_size.to_s
      @unit_system = unit_system.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      height_inches = @unit_system == "imperial" ? @height : @height / 2.54

      devine = calculate_devine(height_inches)
      robinson = calculate_robinson(height_inches)
      miller = calculate_miller(height_inches)
      hamwi = calculate_hamwi(height_inches)

      average = (devine + robinson + miller + hamwi) / 4.0
      frame_adjusted = apply_frame_adjustment(average)

      # Convert to display units
      if @unit_system == "imperial"
        {
          valid: true,
          devine: devine.round(1),
          robinson: robinson.round(1),
          miller: miller.round(1),
          hamwi: hamwi.round(1),
          average: average.round(1),
          frame_adjusted: frame_adjusted.round(1),
          ideal_range_min: (frame_adjusted * 0.90).round(1),
          ideal_range_max: (frame_adjusted * 1.10).round(1),
          unit: "lbs"
        }
      else
        {
          valid: true,
          devine: kg(devine).round(1),
          robinson: kg(robinson).round(1),
          miller: kg(miller).round(1),
          hamwi: kg(hamwi).round(1),
          average: kg(average).round(1),
          frame_adjusted: kg(frame_adjusted).round(1),
          ideal_range_min: kg(frame_adjusted * 0.90).round(1),
          ideal_range_max: kg(frame_adjusted * 1.10).round(1),
          unit: "kg"
        }
      end
    end

    private

    def kg(lbs)
      lbs * 0.453592
    end

    # Devine formula (1974)
    # Male: 50 + 2.3 kg per inch over 5 ft
    # Female: 45.5 + 2.3 kg per inch over 5 ft
    def calculate_devine(height_inches)
      inches_over = [ height_inches - BASE_HEIGHT_INCHES, 0 ].max
      if @gender == "male"
        lbs(50.0 + 2.3 * inches_over)
      else
        lbs(45.5 + 2.3 * inches_over)
      end
    end

    # Robinson formula (1983)
    # Male: 52 + 1.9 kg per inch over 5 ft
    # Female: 49 + 1.7 kg per inch over 5 ft
    def calculate_robinson(height_inches)
      inches_over = [ height_inches - BASE_HEIGHT_INCHES, 0 ].max
      if @gender == "male"
        lbs(52.0 + 1.9 * inches_over)
      else
        lbs(49.0 + 1.7 * inches_over)
      end
    end

    # Miller formula (1983)
    # Male: 56.2 + 1.41 kg per inch over 5 ft
    # Female: 53.1 + 1.36 kg per inch over 5 ft
    def calculate_miller(height_inches)
      inches_over = [ height_inches - BASE_HEIGHT_INCHES, 0 ].max
      if @gender == "male"
        lbs(56.2 + 1.41 * inches_over)
      else
        lbs(53.1 + 1.36 * inches_over)
      end
    end

    # Hamwi formula (1964)
    # Male: 48 + 2.7 kg per inch over 5 ft
    # Female: 45.5 + 2.2 kg per inch over 5 ft
    def calculate_hamwi(height_inches)
      inches_over = [ height_inches - BASE_HEIGHT_INCHES, 0 ].max
      if @gender == "male"
        lbs(48.0 + 2.7 * inches_over)
      else
        lbs(45.5 + 2.2 * inches_over)
      end
    end

    # Convert kg to lbs (formulas give kg, we work in lbs internally)
    def lbs(kg_value)
      kg_value * 2.20462
    end

    # Frame size adjustments: small -10%, medium 0%, large +10%
    FRAME_ADJUSTMENTS = {
      "small" => 0.90,
      "medium" => 1.00,
      "large" => 1.10
    }.freeze

    def apply_frame_adjustment(weight_lbs)
      weight_lbs * FRAME_ADJUSTMENTS[@frame_size]
    end

    def validate!
      @errors << "Height must be positive" unless @height > 0
      @errors << "Gender must be male or female" unless %w[male female].include?(@gender)
      @errors << "Frame size must be small, medium, or large" unless FRAME_ADJUSTMENTS.key?(@frame_size)
      @errors << "Invalid unit system" unless %w[metric imperial].include?(@unit_system)
    end
  end
end
