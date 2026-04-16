# frozen_string_literal: true

module Health
  class PregnancyWeightCalculator
    attr_reader :errors

    # IOM (Institute of Medicine) weight gain guidelines by pre-pregnancy BMI
    IOM_GUIDELINES = {
      underweight:  { total_min: 12.7, total_max: 18.1, weekly_rate: 0.51 },
      normal:       { total_min: 11.3, total_max: 15.9, weekly_rate: 0.42 },
      overweight:   { total_min: 6.8,  total_max: 11.3, weekly_rate: 0.28 },
      obese:        { total_min: 5.0,  total_max: 9.1,  weekly_rate: 0.22 }
    }.freeze

    # First trimester typically sees 0.5-2 kg of total gain
    FIRST_TRI_GAIN_MIN = 0.5
    FIRST_TRI_GAIN_MAX = 2.0
    FIRST_TRI_END_WEEK = 13

    def initialize(pre_pregnancy_weight_kg:, height_cm:, current_week:)
      @weight = pre_pregnancy_weight_kg.to_f
      @height = height_cm.to_f
      @current_week = current_week.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      bmi = calculate_bmi
      category = categorize(bmi)
      guidelines = IOM_GUIDELINES[category]
      weekly_rate = guidelines[:weekly_rate]

      current_gain = calculate_current_expected_gain(weekly_rate)

      {
        valid: true,
        pre_pregnancy_bmi: bmi.round(1),
        bmi_category: format_category(category),
        recommended_total_gain_range: {
          min: guidelines[:total_min],
          max: guidelines[:total_max]
        },
        current_expected_gain_range: {
          min: current_gain[:min].round(1),
          max: current_gain[:max].round(1)
        },
        weekly_gain_rate: weekly_rate
      }
    end

    private

    def calculate_bmi
      height_m = @height / 100.0
      @weight / (height_m**2)
    end

    def categorize(bmi)
      case bmi
      when 0...18.5 then :underweight
      when 18.5...25 then :normal
      when 25...30 then :overweight
      else :obese
      end
    end

    def format_category(category)
      case category
      when :underweight then "Underweight"
      when :normal then "Normal weight"
      when :overweight then "Overweight"
      when :obese then "Obese"
      end
    end

    def calculate_current_expected_gain(weekly_rate)
      if @current_week <= FIRST_TRI_END_WEEK
        # During first trimester, gain is proportional within 0.5-2 kg range
        fraction = @current_week.to_f / FIRST_TRI_END_WEEK
        {
          min: FIRST_TRI_GAIN_MIN * fraction,
          max: FIRST_TRI_GAIN_MAX * fraction
        }
      else
        # Past first trimester: first-tri gain + weekly rate for remaining weeks
        weeks_past_first_tri = @current_week - FIRST_TRI_END_WEEK
        additional = weekly_rate * weeks_past_first_tri
        {
          min: FIRST_TRI_GAIN_MIN + additional,
          max: FIRST_TRI_GAIN_MAX + additional
        }
      end
    end

    def validate!
      @errors << "Pre-pregnancy weight must be positive" unless @weight > 0
      @errors << "Height must be positive" unless @height > 0
      @errors << "Current week must be between 1 and 42" unless @current_week >= 1 && @current_week <= 42
      @errors << "Weight cannot exceed 300 kg" if @weight > 300
      @errors << "Height cannot exceed 300 cm" if @height > 300
    end
  end
end
