# frozen_string_literal: true

module Construction
  class DrywallCalculator
    attr_reader :errors

    DOOR_AREA_SQFT = 21
    WINDOW_AREA_SQFT = 15
    WASTE_FACTOR = 1.10
    JOINT_COMPOUND_SQFT_PER_GALLON = 100
    TAPE_SQFT_PER_ROLL = 50

    VALID_SHEET_SIZES = [ 32, 48 ].freeze

    def initialize(room_length_ft:, room_width_ft:, room_height_ft:, num_doors: 1, num_windows: 1, sheet_size: 32)
      @room_length_ft = room_length_ft.to_f
      @room_width_ft = room_width_ft.to_f
      @room_height_ft = room_height_ft.to_f
      @num_doors = num_doors.to_i
      @num_windows = num_windows.to_i
      @sheet_size = sheet_size.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      perimeter = 2 * (@room_length_ft + @room_width_ft)
      total_wall_area = perimeter * @room_height_ft
      openings = (@num_doors * DOOR_AREA_SQFT) + (@num_windows * WINDOW_AREA_SQFT)
      net_area = [ total_wall_area - openings, 0 ].max

      sheets_needed = (net_area / @sheet_size.to_f * WASTE_FACTOR).ceil
      joint_compound_gallons = (net_area / JOINT_COMPOUND_SQFT_PER_GALLON.to_f).ceil
      tape_rolls = (net_area / TAPE_SQFT_PER_ROLL.to_f).ceil

      {
        valid: true,
        total_wall_area_sqft: total_wall_area.round(2),
        net_area_sqft: net_area.round(2),
        sheets_needed: sheets_needed,
        joint_compound_gallons: joint_compound_gallons,
        tape_rolls: tape_rolls
      }
    end

    private

    def validate!
      @errors << "Room length must be greater than zero" unless @room_length_ft.positive?
      @errors << "Room width must be greater than zero" unless @room_width_ft.positive?
      @errors << "Room height must be greater than zero" unless @room_height_ft.positive?
      @errors << "Number of doors cannot be negative" if @num_doors.negative?
      @errors << "Number of windows cannot be negative" if @num_windows.negative?
      @errors << "Sheet size must be 32 or 48 sq ft" unless VALID_SHEET_SIZES.include?(@sheet_size)
    end
  end
end
