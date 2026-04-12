# frozen_string_literal: true

module Construction
  class BrickBlockCalculator
    attr_reader :errors

    UNIT_TYPES = {
      "standard_brick" => { length_in: 8.0, height_in: 2.25, mortar_joint_in: 0.375, per_sqft: 6.75, label: "Standard Brick (8\" x 2.25\" x 3.5\")" },
      "modular_brick" => { length_in: 7.625, height_in: 2.25, mortar_joint_in: 0.375, per_sqft: 6.86, label: "Modular Brick (7.625\" x 2.25\" x 3.625\")" },
      "king_brick" => { length_in: 9.625, height_in: 2.75, mortar_joint_in: 0.375, per_sqft: 4.80, label: "King Size Brick (9.625\" x 2.75\" x 2.75\")" },
      "cmu_8" => { length_in: 16.0, height_in: 8.0, mortar_joint_in: 0.375, per_sqft: 1.125, label: "CMU Block 8\" (16\" x 8\" x 8\")" },
      "cmu_12" => { length_in: 16.0, height_in: 8.0, mortar_joint_in: 0.375, per_sqft: 1.125, label: "CMU Block 12\" (16\" x 8\" x 12\")" }
    }.freeze

    WASTE_FACTOR = 1.10

    def initialize(wall_length_ft:, wall_height_ft:, unit_type: "standard_brick", openings_sqft: 0)
      @wall_length_ft = wall_length_ft.to_f
      @wall_height_ft = wall_height_ft.to_f
      @unit_type = unit_type.to_s.downcase
      @openings_sqft = openings_sqft.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      unit = UNIT_TYPES[@unit_type]

      gross_area_sqft = @wall_length_ft * @wall_height_ft
      net_area_sqft = gross_area_sqft - @openings_sqft
      net_area_sqft = 0.0 if net_area_sqft.negative?

      # Calculate using unit-with-mortar dimensions
      unit_with_mortar_length = unit[:length_in] + unit[:mortar_joint_in]
      unit_with_mortar_height = unit[:height_in] + unit[:mortar_joint_in]

      units_per_sqft = (144.0 / (unit_with_mortar_length * unit_with_mortar_height)).round(2)

      units_needed_raw = (net_area_sqft * units_per_sqft).ceil
      units_needed = (units_needed_raw * WASTE_FACTOR).ceil

      # Mortar estimate: approximately 7 bags per 1000 standard bricks, or based on area
      mortar_bags = if @unit_type.start_with?("cmu")
        (net_area_sqft / 35.0).ceil  # ~1 bag per 35 sqft for CMU
      else
        (units_needed / 140.0).ceil  # ~1 bag per 140 bricks
      end

      {
        valid: true,
        unit_label: unit[:label],
        gross_area_sqft: gross_area_sqft.round(1),
        net_area_sqft: net_area_sqft.round(1),
        units_per_sqft: units_per_sqft,
        units_needed: units_needed,
        waste_units: units_needed - units_needed_raw,
        mortar_bags: mortar_bags
      }
    end

    private

    def validate!
      @errors << "Wall length must be greater than zero" unless @wall_length_ft.positive?
      @errors << "Wall height must be greater than zero" unless @wall_height_ft.positive?
      @errors << "Invalid unit type" unless UNIT_TYPES.key?(@unit_type)
      @errors << "Openings cannot be negative" if @openings_sqft.negative?
      if @wall_length_ft.positive? && @wall_height_ft.positive? && @openings_sqft >= (@wall_length_ft * @wall_height_ft)
        @errors << "Openings cannot exceed wall area"
      end
    end
  end
end
