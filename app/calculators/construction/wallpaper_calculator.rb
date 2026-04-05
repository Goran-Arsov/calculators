# frozen_string_literal: true

module Construction
  class WallpaperCalculator
    attr_reader :errors

    STANDARD_ROLL_WIDTH_IN = 20.5
    STANDARD_ROLL_LENGTH_FT = 33.0  # American single roll ~33 ft
    DOOR_AREA_SQFT = 21
    WINDOW_AREA_SQFT = 15

    def initialize(length:, width:, height:, doors: 1, windows: 2, pattern_repeat_in: 0)
      @length = length.to_f
      @width = width.to_f
      @height = height.to_f
      @doors = doors.to_i
      @windows = windows.to_i
      @pattern_repeat_in = pattern_repeat_in.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      # Wall area
      perimeter = 2 * (@length + @width)
      wall_area = perimeter * @height
      opening_area = (@doors * DOOR_AREA_SQFT) + (@windows * WINDOW_AREA_SQFT)
      coverable_area = [ wall_area - opening_area, 0 ].max

      # Roll coverage: account for pattern repeat waste
      roll_width_ft = STANDARD_ROLL_WIDTH_IN / 12.0
      usable_length_per_strip = STANDARD_ROLL_LENGTH_FT

      if @pattern_repeat_in > 0
        pattern_repeat_ft = @pattern_repeat_in / 12.0
        # Each strip must be cut to a multiple of the pattern repeat
        strips_per_height = (@height / pattern_repeat_ft).ceil
        adjusted_strip_height = strips_per_height * pattern_repeat_ft
        usable_length_per_strip = STANDARD_ROLL_LENGTH_FT
        strips_per_roll = (usable_length_per_strip / adjusted_strip_height).floor
      else
        strips_per_roll = (STANDARD_ROLL_LENGTH_FT / @height).floor
      end

      strips_per_roll = [ strips_per_roll, 1 ].max

      # Total strips needed
      total_strips = (perimeter / roll_width_ft).ceil

      # Subtract strips for doors/windows (rough: each opening saves ~1 strip)
      saved_strips = @doors + @windows
      net_strips = [ total_strips - saved_strips, 1 ].max

      # Total rolls
      rolls_needed = (net_strips / strips_per_roll.to_f).ceil

      # Usable coverage per roll
      coverage_per_roll = strips_per_roll * roll_width_ft * @height

      {
        wall_area: wall_area.round(2),
        coverable_area: coverable_area.round(2),
        perimeter: perimeter.round(2),
        total_strips: total_strips,
        strips_per_roll: strips_per_roll,
        rolls_needed: rolls_needed,
        coverage_per_roll: coverage_per_roll.round(2)
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length.positive?
      @errors << "Width must be greater than zero" unless @width.positive?
      @errors << "Height must be greater than zero" unless @height.positive?
      @errors << "Doors cannot be negative" if @doors.negative?
      @errors << "Windows cannot be negative" if @windows.negative?
      @errors << "Pattern repeat cannot be negative" if @pattern_repeat_in.negative?
    end
  end
end
