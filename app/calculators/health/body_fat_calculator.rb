module Health
  class BodyFatCalculator
    attr_reader :errors

    def initialize(sex:, waist:, neck:, height:, hip: nil, unit_system: "metric")
      @sex = sex.to_s
      @waist = waist.to_f
      @neck = neck.to_f
      @height = height.to_f
      @hip = hip&.to_f
      @unit_system = unit_system.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      waist_cm = @unit_system == "imperial" ? @waist * 2.54 : @waist
      neck_cm = @unit_system == "imperial" ? @neck * 2.54 : @neck
      height_cm = @unit_system == "imperial" ? @height * 2.54 : @height
      hip_cm = @hip && @unit_system == "imperial" ? @hip * 2.54 : @hip

      body_fat = calculate_body_fat(waist_cm, neck_cm, height_cm, hip_cm)
      category = categorize(body_fat)

      {
        valid: true,
        body_fat_percentage: body_fat.round(1),
        category: category
      }
    end

    private

    # U.S. Navy Method
    def calculate_body_fat(waist, neck, height, hip)
      if @sex == "male"
        495 / (1.0324 - 0.19077 * ::Math.log10(waist - neck) + 0.15456 * ::Math.log10(height)) - 450
      else
        495 / (1.29579 - 0.35004 * ::Math.log10(waist + hip - neck) + 0.22100 * ::Math.log10(height)) - 450
      end
    end

    def categorize(bf)
      if @sex == "male"
        case bf
        when 0...6 then "Essential fat"
        when 6...14 then "Athletes"
        when 14...18 then "Fitness"
        when 18...25 then "Average"
        else "Obese"
        end
      else
        case bf
        when 0...14 then "Essential fat"
        when 14...21 then "Athletes"
        when 21...25 then "Fitness"
        when 25...32 then "Average"
        else "Obese"
        end
      end
    end

    def validate!
      @errors << "Sex must be male or female" unless %w[male female].include?(@sex)
      @errors << "Waist measurement must be positive" unless @waist > 0
      @errors << "Neck measurement must be positive" unless @neck > 0
      @errors << "Height must be positive" unless @height > 0
      @errors << "Waist must be larger than neck" unless @waist > @neck
      @errors << "Hip measurement is required for females" if @sex == "female" && (@hip.nil? || @hip <= 0)
      @errors << "Invalid unit system" unless %w[metric imperial].include?(@unit_system)
    end
  end
end
