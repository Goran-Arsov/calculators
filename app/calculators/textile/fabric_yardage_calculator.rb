# frozen_string_literal: true

module Textile
  class FabricYardageCalculator
    attr_reader :errors

    def initialize(piece_length_in:, piece_width_in:, num_pieces:, fabric_width_in:, repeat_in: 0)
      @piece_length_in = piece_length_in.to_f
      @piece_width_in = piece_width_in.to_f
      @num_pieces = num_pieces.to_i
      @fabric_width_in = fabric_width_in.to_f
      @repeat_in = repeat_in.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      pieces_across = (@fabric_width_in / @piece_width_in).floor

      if pieces_across.zero?
        @errors << "Piece width exceeds fabric width"
        return { valid: false, errors: @errors }
      end

      rows_needed = (@num_pieces.to_f / pieces_across).ceil

      effective_length =
        if @repeat_in.positive?
          (@piece_length_in / @repeat_in).ceil * @repeat_in
        else
          @piece_length_in
        end

      total_length_in = rows_needed * effective_length
      total_yards = total_length_in / 36.0
      total_meters = total_length_in * 0.0254

      {
        valid: true,
        pieces_across: pieces_across,
        rows_needed: rows_needed,
        total_length_in: total_length_in.round(2),
        total_yards: total_yards.round(3),
        total_meters: total_meters.round(3)
      }
    end

    private

    def validate!
      @errors << "Piece length must be greater than zero" unless @piece_length_in.positive?
      @errors << "Piece width must be greater than zero" unless @piece_width_in.positive?
      @errors << "Number of pieces must be at least 1" unless @num_pieces >= 1
      @errors << "Fabric width must be greater than zero" unless @fabric_width_in.positive?
      @errors << "Pattern repeat cannot be negative" if @repeat_in.negative?
    end
  end
end
