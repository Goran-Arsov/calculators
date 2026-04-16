# frozen_string_literal: true

module Health
  class BloodPressureCalculator
    attr_reader :errors

    # AHA/ACC Blood Pressure Categories
    # Based on American Heart Association guidelines
    CATEGORIES = [
      { name: "Hypotension", systolic_range: 0...90, diastolic_range: 0...60, color: "blue", risk: "low" },
      { name: "Normal", systolic_range: 0...120, diastolic_range: 0...80, color: "green", risk: "low" },
      { name: "Elevated", systolic_range: 120...130, diastolic_range: 0...80, color: "yellow", risk: "moderate" },
      { name: "High Blood Pressure Stage 1", systolic_range: 130...140, diastolic_range: 80...90, color: "orange", risk: "moderate" },
      { name: "High Blood Pressure Stage 2", systolic_range: 140...180, diastolic_range: 90...120, color: "red", risk: "high" },
      { name: "Hypertensive Crisis", systolic_range: 180..Float::INFINITY, diastolic_range: 120..Float::INFINITY, color: "darkred", risk: "critical" }
    ].freeze

    def initialize(systolic:, diastolic:)
      @systolic = systolic.to_i
      @diastolic = diastolic.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      category = categorize
      pulse_pressure = @systolic - @diastolic
      map = calculate_map

      {
        valid: true,
        systolic: @systolic,
        diastolic: @diastolic,
        category: category[:name],
        risk_level: category[:risk],
        pulse_pressure: pulse_pressure,
        mean_arterial_pressure: map.round(1),
        recommendation: recommendation_for(category[:name])
      }
    end

    private

    # Categorize based on the HIGHER category of systolic or diastolic
    # Per AHA guidelines, the higher reading determines the category
    def categorize
      # Check from most severe to least severe
      if @systolic >= 180 || @diastolic >= 120
        CATEGORIES[5] # Hypertensive Crisis
      elsif @systolic.between?(140, 179) || @diastolic.between?(90, 119)
        CATEGORIES[4] # Stage 2
      elsif @systolic.between?(130, 139) || @diastolic.between?(80, 89)
        CATEGORIES[3] # Stage 1
      elsif @systolic.between?(120, 129) && @diastolic < 80
        CATEGORIES[2] # Elevated
      elsif @systolic < 90 || @diastolic < 60
        CATEGORIES[0] # Hypotension
      else
        CATEGORIES[1] # Normal
      end
    end

    # Mean Arterial Pressure = DBP + 1/3(SBP - DBP)
    def calculate_map
      @diastolic + ((@systolic - @diastolic) / 3.0)
    end

    def recommendation_for(category_name)
      case category_name
      when "Hypotension"
        "Your blood pressure is lower than normal. If you experience dizziness, fainting, or fatigue, consult your doctor. Stay hydrated and consider increasing salt intake if advised by your physician."
      when "Normal"
        "Your blood pressure is within the healthy range. Continue maintaining a healthy lifestyle with regular exercise, balanced diet, and stress management."
      when "Elevated"
        "Your blood pressure is slightly above normal. Lifestyle changes such as reducing sodium intake, increasing physical activity, and managing stress can help prevent progression to hypertension."
      when "High Blood Pressure Stage 1"
        "You may have Stage 1 hypertension. Consult your healthcare provider about lifestyle modifications and whether medication is needed. Monitor your blood pressure regularly."
      when "High Blood Pressure Stage 2"
        "You may have Stage 2 hypertension. See your healthcare provider promptly. A combination of lifestyle changes and medication is typically recommended at this stage."
      when "Hypertensive Crisis"
        "This reading indicates a hypertensive crisis. If you also have symptoms such as chest pain, shortness of breath, or vision changes, call emergency services immediately. Otherwise, contact your doctor right away."
      end
    end

    def validate!
      @errors << "Systolic pressure must be positive" unless @systolic > 0
      @errors << "Diastolic pressure must be positive" unless @diastolic > 0
      @errors << "Systolic pressure must be between 60 and 300 mmHg" unless @systolic.between?(60, 300)
      @errors << "Diastolic pressure must be between 30 and 200 mmHg" unless @diastolic.between?(30, 200)
      @errors << "Systolic must be greater than diastolic" unless @systolic > @diastolic
    end
  end
end
