# frozen_string_literal: true

module Construction
  class CaulkCalculator
    attr_reader :errors

    # Tube yield in fluid ounces by common tube size.
    TUBE_FL_OZ = {
      "10.1" => 10.1, # standard caulk gun cartridge
      "20"   => 20.0, # sausage pack
      "28"   => 28.0  # oversize sausage
    }.freeze

    # 1 fluid ounce = 1.80469 cubic inches (US fluid ounce).
    CUIN_PER_FL_OZ = 1.80469
    DEFAULT_WASTE_PCT = 10.0

    def initialize(length_ft:, joint_width_in:, joint_depth_in:, tube_size: "10.1", waste_pct: DEFAULT_WASTE_PCT)
      @length_ft = length_ft.to_f
      @width_in = joint_width_in.to_f
      @depth_in = joint_depth_in.to_f
      @tube_size = tube_size.to_s
      @waste_pct = waste_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      length_in = @length_ft * 12.0
      joint_volume_cuin = length_in * @width_in * @depth_in
      tube_volume_cuin = TUBE_FL_OZ[@tube_size] * CUIN_PER_FL_OZ
      tubes_exact = joint_volume_cuin / tube_volume_cuin
      tubes_with_waste = (tubes_exact * (1 + @waste_pct / 100.0)).round(6).ceil

      # Linear feet covered per tube at this joint profile
      linear_ft_per_tube = (tube_volume_cuin / (@width_in * @depth_in)) / 12.0

      {
        valid: true,
        length_in: length_in.round(2),
        joint_volume_cuin: joint_volume_cuin.round(2),
        tube_volume_cuin: tube_volume_cuin.round(2),
        tube_fl_oz: TUBE_FL_OZ[@tube_size],
        linear_ft_per_tube: linear_ft_per_tube.round(2),
        tubes_exact: tubes_exact.round(2),
        tubes_with_waste: tubes_with_waste
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Joint width must be greater than zero" unless @width_in.positive?
      @errors << "Joint depth must be greater than zero" unless @depth_in.positive?
      @errors << "Tube size must be 10.1, 20, or 28" unless TUBE_FL_OZ.key?(@tube_size)
      @errors << "Waste percent cannot be negative" if @waste_pct.negative?
    end
  end
end
