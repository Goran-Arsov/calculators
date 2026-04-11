# frozen_string_literal: true

module Construction
  class SidingCalculator
    attr_reader :errors

    SQFT_PER_SQUARE = 100.0
    DEFAULT_WINDOW_SQFT = 15.0
    DEFAULT_DOOR_SQFT = 21.0

    def initialize(wall_length_ft:, wall_height_ft:,
                   gable_length_ft: 0, gable_height_ft: 0,
                   windows: 0, doors: 0,
                   window_sqft: DEFAULT_WINDOW_SQFT, door_sqft: DEFAULT_DOOR_SQFT,
                   waste_pct: 10)
      @wall_length_ft = wall_length_ft.to_f
      @wall_height_ft = wall_height_ft.to_f
      @gable_length_ft = gable_length_ft.to_f
      @gable_height_ft = gable_height_ft.to_f
      @windows = windows.to_i
      @doors = doors.to_i
      @window_sqft = window_sqft.to_f
      @door_sqft = door_sqft.to_f
      @waste_pct = waste_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      wall_area = @wall_length_ft * @wall_height_ft
      gable_area = 0.5 * @gable_length_ft * @gable_height_ft
      gross_area = wall_area + gable_area
      openings_area = (@windows * @window_sqft) + (@doors * @door_sqft)
      net_area = [ gross_area - openings_area, 0 ].max
      with_waste = net_area * (1 + @waste_pct / 100.0)
      squares = with_waste / SQFT_PER_SQUARE

      {
        valid: true,
        wall_area_sqft: wall_area.round(2),
        gable_area_sqft: gable_area.round(2),
        gross_area_sqft: gross_area.round(2),
        openings_area_sqft: openings_area.round(2),
        net_area_sqft: net_area.round(2),
        with_waste_sqft: with_waste.round(2),
        squares: squares.round(2)
      }
    end

    private

    def validate!
      @errors << "Wall length must be greater than zero" unless @wall_length_ft.positive?
      @errors << "Wall height must be greater than zero" unless @wall_height_ft.positive?
      @errors << "Windows cannot be negative" if @windows.negative?
      @errors << "Doors cannot be negative" if @doors.negative?
      @errors << "Gable dimensions cannot be negative" if @gable_length_ft.negative? || @gable_height_ft.negative?
      @errors << "Waste percent cannot be negative" if @waste_pct.negative?
    end
  end
end
