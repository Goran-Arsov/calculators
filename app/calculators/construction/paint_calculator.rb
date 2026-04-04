# frozen_string_literal: true

module Construction
  class PaintCalculator
    attr_reader :errors

    DOOR_AREA_SQFT = 21
    WINDOW_AREA_SQFT = 15
    COVERAGE_SQFT_PER_GALLON = 350

    def initialize(length:, width:, height:, coats: 2, doors: 1, windows: 2)
      @length = length.to_f
      @width = width.to_f
      @height = height.to_f
      @coats = coats.to_i
      @doors = doors.to_i
      @windows = windows.to_i
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      wall_area = 2 * (@length + @width) * @height
      door_area = @doors * DOOR_AREA_SQFT
      window_area = @windows * WINDOW_AREA_SQFT
      paintable_area = wall_area - door_area - window_area
      paintable_area = 0 if paintable_area.negative?

      raw_gallons = (paintable_area * @coats) / COVERAGE_SQFT_PER_GALLON.to_f
      gallons = (raw_gallons * 2).ceil / 2.0

      {
        wall_area: wall_area.round(2),
        paintable_area: paintable_area.round(2),
        gallons: gallons
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length.positive?
      @errors << "Width must be greater than zero" unless @width.positive?
      @errors << "Height must be greater than zero" unless @height.positive?
      @errors << "Coats must be at least 1" unless @coats >= 1
      @errors << "Doors cannot be negative" if @doors.negative?
      @errors << "Windows cannot be negative" if @windows.negative?
    end
  end
end
