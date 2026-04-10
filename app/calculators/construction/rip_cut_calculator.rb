# frozen_string_literal: true

module Construction
  class RipCutCalculator
    attr_reader :errors

    def initialize(board_width:, rip_width:, kerf_width: 0.125)
      @board_width = board_width.to_f
      @rip_width = rip_width.to_f
      @kerf_width = kerf_width.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @rip_width > @board_width
        return {
          valid: true,
          board_width: @board_width.round(4),
          rip_width: @rip_width.round(4),
          kerf_width: @kerf_width.round(4),
          num_strips: 0,
          material_used: 0.0,
          kerf_waste: 0.0,
          leftover: @board_width.round(4),
          efficiency_percent: 0.0
        }
      end

      # N <= (board_width + kerf_width) / (rip_width + kerf_width)
      num_strips = ((@board_width + @kerf_width) / (@rip_width + @kerf_width)).floor
      num_strips = 0 if num_strips.negative?

      cuts = [num_strips - 1, 0].max
      material_used = num_strips * @rip_width + cuts * @kerf_width
      kerf_waste = cuts * @kerf_width
      leftover = @board_width - material_used
      efficiency_percent =
        if @board_width.positive?
          (num_strips * @rip_width) / @board_width * 100.0
        else
          0.0
        end

      {
        valid: true,
        board_width: @board_width.round(4),
        rip_width: @rip_width.round(4),
        kerf_width: @kerf_width.round(4),
        num_strips: num_strips,
        material_used: material_used.round(4),
        kerf_waste: kerf_waste.round(4),
        leftover: leftover.round(4),
        efficiency_percent: efficiency_percent.round(2)
      }
    end

    private

    def validate!
      @errors << "Board width must be greater than zero" unless @board_width.positive?
      @errors << "Rip width must be greater than zero" unless @rip_width.positive?
      @errors << "Kerf width cannot be negative" if @kerf_width.negative?
    end
  end
end
