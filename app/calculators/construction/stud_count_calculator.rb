# frozen_string_literal: true

module Construction
  class StudCountCalculator
    attr_reader :errors

    # Standard wall framing conventions:
    # - One stud every "spacing" inches on center, plus one at the far end.
    # - 2 extra studs per corner (L-corner) or 3 per T-intersection.
    # - 2 jack studs + 2 king studs per opening (door or window).
    # - Two top plates (doubled) and one bottom plate — 3× wall length of plate stock.
    VALID_SPACINGS = [ 12, 16, 19.2, 24 ].freeze

    def initialize(wall_length_ft:, wall_height_ft:, spacing_in: 16, corners: 2, openings: 0)
      @wall_length_ft = wall_length_ft.to_f
      @wall_height_ft = wall_height_ft.to_f
      @spacing_in = spacing_in.to_f
      @corners = corners.to_i
      @openings = openings.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      length_in = @wall_length_ft * 12.0
      field_studs = (length_in / @spacing_in).ceil + 1
      corner_studs = @corners * 2           # 2 extra per L-corner
      opening_studs = @openings * 4          # 2 jack + 2 king per opening
      total_studs = field_studs + corner_studs + opening_studs

      # Plate stock: 3× wall length (bottom plate + doubled top plate).
      plate_linear_ft = (@wall_length_ft * 3).round(2)

      # Stud linear feet from wall height (one piece per stud at wall height).
      stud_stock_linear_ft = (total_studs * @wall_height_ft).round(2)

      {
        valid: true,
        field_studs: field_studs,
        corner_studs: corner_studs,
        opening_studs: opening_studs,
        total_studs: total_studs,
        plate_linear_ft: plate_linear_ft,
        stud_stock_linear_ft: stud_stock_linear_ft,
        spacing_in: @spacing_in
      }
    end

    private

    def validate!
      @errors << "Wall length must be greater than zero" unless @wall_length_ft.positive?
      @errors << "Wall height must be greater than zero" unless @wall_height_ft.positive?
      @errors << "Spacing must be 12, 16, 19.2, or 24 inches" unless VALID_SPACINGS.include?(@spacing_in)
      @errors << "Corners cannot be negative" if @corners.negative?
      @errors << "Openings cannot be negative" if @openings.negative?
    end
  end
end
