module Health
  class WristHeightRatioCalculator
    attr_reader :errors

    # Frame size classifications by wrist circumference
    # Based on wrist-to-height ratio and gender
    FRAME_SIZES = {
      "male" => {
        small: { max_wrist_cm: 16.5, label: "Small Frame" },
        medium: { min_wrist_cm: 16.5, max_wrist_cm: 19.0, label: "Medium Frame" },
        large: { min_wrist_cm: 19.0, label: "Large Frame" }
      },
      "female" => {
        small: { max_wrist_cm: 14.0, label: "Small Frame" },
        medium: { min_wrist_cm: 14.0, max_wrist_cm: 16.5, label: "Medium Frame" },
        large: { min_wrist_cm: 16.5, label: "Large Frame" }
      }
    }.freeze

    # Ideal weight ranges by frame size using height (Hamwi method base)
    # Adjustments: small frame -10%, large frame +10%
    FRAME_ADJUSTMENT = {
      small: -0.10,
      medium: 0.0,
      large: 0.10
    }.freeze

    def initialize(wrist_circumference:, height:, gender:, unit: "cm")
      @wrist = wrist_circumference.to_f
      @height = height.to_f
      @gender = gender.to_s.downcase
      @unit = unit.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      wrist_cm = @unit == "inches" ? @wrist * 2.54 : @wrist
      height_cm = @unit == "inches" ? @height * 2.54 : @height

      ratio = wrist_cm / height_cm
      frame_size = determine_frame_size(wrist_cm)
      ideal_weight_range = calculate_ideal_weight(height_cm, frame_size)

      {
        valid: true,
        wrist_cm: wrist_cm.round(1),
        wrist_inches: (wrist_cm / 2.54).round(2),
        height_cm: height_cm.round(1),
        height_inches: (height_cm / 2.54).round(1),
        height_feet_inches: cm_to_feet_inches(height_cm),
        wrist_to_height_ratio: ratio.round(4),
        ratio_percentage: (ratio * 100).round(2),
        frame_size: frame_size,
        frame_size_label: FRAME_SIZES[@gender][frame_size][:label],
        ideal_weight_kg: ideal_weight_range[:kg],
        ideal_weight_lbs: ideal_weight_range[:lbs],
        gender: @gender,
        frame_size_ranges: frame_size_ranges
      }
    end

    private

    def determine_frame_size(wrist_cm)
      frames = FRAME_SIZES[@gender]
      if wrist_cm < frames[:small][:max_wrist_cm]
        :small
      elsif wrist_cm >= frames[:large][:min_wrist_cm]
        :large
      else
        :medium
      end
    end

    def calculate_ideal_weight(height_cm, frame_size)
      # Hamwi formula base weight (medium frame)
      height_inches = height_cm / 2.54

      if @gender == "male"
        # 48 kg for first 152.4 cm (5 ft), + 2.7 kg per 2.54 cm (inch) over 5 ft
        base_kg = 48.0 + ((height_inches - 60) * 2.7).clamp(0, Float::INFINITY)
      else
        # 45.5 kg for first 152.4 cm (5 ft), + 2.2 kg per 2.54 cm (inch) over 5 ft
        base_kg = 45.5 + ((height_inches - 60) * 2.2).clamp(0, Float::INFINITY)
      end

      adjustment = FRAME_ADJUSTMENT[frame_size]
      min_kg = (base_kg * (1 + adjustment) * 0.9).round(1)
      max_kg = (base_kg * (1 + adjustment) * 1.1).round(1)

      {
        kg: { min: min_kg, max: max_kg },
        lbs: { min: (min_kg * 2.20462).round(1), max: (max_kg * 2.20462).round(1) }
      }
    end

    def frame_size_ranges
      FRAME_SIZES[@gender].map do |size, data|
        range = if data[:max_wrist_cm] && data[:min_wrist_cm]
                  "#{data[:min_wrist_cm]} - #{data[:max_wrist_cm]} cm"
                elsif data[:max_wrist_cm]
                  "< #{data[:max_wrist_cm]} cm"
                else
                  "> #{data[:min_wrist_cm]} cm"
                end
        { size: size, label: data[:label], range: range }
      end
    end

    def cm_to_feet_inches(cm)
      total_inches = cm / 2.54
      feet = (total_inches / 12).floor
      inches = (total_inches % 12).round(1)
      "#{feet}'#{inches.round}\""
    end

    def validate!
      @errors << "Wrist circumference must be positive" unless @wrist > 0
      @errors << "Height must be positive" unless @height > 0
      unless %w[male female].include?(@gender)
        @errors << "Gender must be male or female"
      end
      unless %w[cm inches].include?(@unit)
        @errors << "Unit must be cm or inches"
      end
      if @unit == "cm"
        @errors << "Wrist circumference seems unrealistic (max 30 cm)" if @wrist > 30
        @errors << "Height seems unrealistic (max 250 cm)" if @height > 250
      else
        @errors << "Wrist circumference seems unrealistic (max 12 inches)" if @wrist > 12
        @errors << "Height seems unrealistic (max 100 inches)" if @height > 100
      end
    end
  end
end
