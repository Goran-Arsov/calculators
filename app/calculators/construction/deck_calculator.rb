# frozen_string_literal: true

module Construction
  class DeckCalculator
    attr_reader :errors

    JOIST_SPACING_IN = 16       # standard 16" on center
    POST_SPACING_FT = 8         # posts every 8 feet
    SCREWS_PER_BOARD = 20       # ~20 screws per deck board
    SCREWS_PER_BOX = 350        # typical box of deck screws
    DEFAULT_BOARD_LENGTH_FT = 12
    DEFAULT_BOARD_WIDTH_IN = 5.5 # standard 5/4x6 actual width

    def initialize(length:, width:, board_length: DEFAULT_BOARD_LENGTH_FT, board_width: DEFAULT_BOARD_WIDTH_IN, price_per_board: 0)
      @length = length.to_f          # deck length in feet
      @width = width.to_f            # deck width in feet
      @board_length = board_length.to_f
      @board_width = board_width.to_f # board width in inches
      @price_per_board = price_per_board.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      deck_area = @length * @width

      # Decking boards: boards run perpendicular to joists along the width
      board_width_ft = @board_width / 12.0
      boards_across = (@width / board_width_ft).ceil
      board_runs_needed = (@length / @board_length).ceil
      total_boards = boards_across * board_runs_needed

      # Joists: run along the width, spaced 16" OC along the length
      joist_spacing_ft = JOIST_SPACING_IN / 12.0
      num_joists = (@length / joist_spacing_ft).ceil + 1

      # Beams: 2 rim joists (along length)
      rim_joists = 2

      # Posts: spaced every 8ft along each beam, 2 rows
      posts_per_side = ((@length / POST_SPACING_FT).ceil + 1)
      num_posts = posts_per_side * 2

      # Hardware
      total_screws = total_boards * SCREWS_PER_BOARD
      screw_boxes = (total_screws / SCREWS_PER_BOX.to_f).ceil

      # Cost estimate
      board_cost = total_boards * @price_per_board
      total_cost = board_cost # decking boards are the primary cost driver

      {
        valid: true,
        deck_area: deck_area.round(2),
        total_boards: total_boards,
        num_joists: num_joists,
        rim_joists: rim_joists,
        num_posts: num_posts,
        total_screws: total_screws,
        screw_boxes: screw_boxes,
        board_cost: board_cost.round(2),
        total_cost: total_cost.round(2)
      }
    end

    private

    def validate!
      @errors << "Deck length must be greater than zero" unless @length.positive?
      @errors << "Deck width must be greater than zero" unless @width.positive?
      @errors << "Board length must be greater than zero" unless @board_length.positive?
      @errors << "Board width must be greater than zero" unless @board_width.positive?
      @errors << "Price per board cannot be negative" if @price_per_board.negative?
    end
  end
end
