# frozen_string_literal: true

module Construction
  class RetainingWallCalculator
    attr_reader :errors

    WASTE_FACTOR = 1.10
    GRAVEL_BASE_DEPTH_FT = 0.5
    GRAVEL_BASE_WIDTH_FT = 2.0
    BACKFILL_DEPTH_FT = 1.0
    CUBIC_FT_PER_YARD = 27.0

    def initialize(wall_length_ft:, wall_height_ft:, block_height_in: 6, block_length_in: 16)
      @wall_length_ft = wall_length_ft.to_f
      @wall_height_ft = wall_height_ft.to_f
      @block_height_in = block_height_in.to_f
      @block_length_in = block_length_in.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      rows = (@wall_height_ft * 12 / @block_height_in).ceil
      blocks_per_row = (@wall_length_ft * 12 / @block_length_in).ceil
      total_blocks_raw = rows * blocks_per_row
      total_blocks = (total_blocks_raw * WASTE_FACTOR).ceil
      cap_blocks = blocks_per_row

      gravel_cubic_ft = GRAVEL_BASE_DEPTH_FT * GRAVEL_BASE_WIDTH_FT * @wall_length_ft
      gravel_cubic_yards = (gravel_cubic_ft / CUBIC_FT_PER_YARD).round(2)

      backfill_cubic_ft = @wall_height_ft * BACKFILL_DEPTH_FT * @wall_length_ft
      backfill_cubic_yards = (backfill_cubic_ft / CUBIC_FT_PER_YARD).round(2)

      {
        valid: true,
        rows: rows,
        blocks_per_row: blocks_per_row,
        total_blocks: total_blocks,
        cap_blocks: cap_blocks,
        gravel_cubic_yards: gravel_cubic_yards,
        backfill_cubic_yards: backfill_cubic_yards
      }
    end

    private

    def validate!
      @errors << "Wall length must be greater than zero" unless @wall_length_ft.positive?
      @errors << "Wall height must be greater than zero" unless @wall_height_ft.positive?
      @errors << "Block height must be greater than zero" unless @block_height_in.positive?
      @errors << "Block length must be greater than zero" unless @block_length_in.positive?
    end
  end
end
