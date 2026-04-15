# frozen_string_literal: true

module Construction
  class JoistCalculator
    attr_reader :errors

    # IRC Table R502.3.1(1) — 40 psf live load, 10 psf dead load, L/360 deflection.
    # Values are maximum allowed clear span in feet. Subset for the most common
    # residential lumber. Spans are approximate; consult the full IRC table for
    # code enforcement.
    MAX_SPAN_FT = {
      "2x6" => {
        "12" => { "spf_2" => 10.75, "syp_2" => 10.75, "df_2" => 10.75 },
        "16" => { "spf_2" => 9.75, "syp_2" => 9.75, "df_2" => 9.75 },
        "24" => { "spf_2" => 8.5, "syp_2" => 8.5, "df_2" => 8.5 }
      },
      "2x8" => {
        "12" => { "spf_2" => 14.17, "syp_2" => 14.17, "df_2" => 14.17 },
        "16" => { "spf_2" => 12.67, "syp_2" => 12.83, "df_2" => 12.83 },
        "24" => { "spf_2" => 11.0, "syp_2" => 11.08, "df_2" => 11.08 }
      },
      "2x10" => {
        "12" => { "spf_2" => 18.0, "syp_2" => 18.0, "df_2" => 18.0 },
        "16" => { "spf_2" => 15.42, "syp_2" => 16.17, "df_2" => 16.17 },
        "24" => { "spf_2" => 12.58, "syp_2" => 13.17, "df_2" => 13.17 }
      },
      "2x12" => {
        "12" => { "spf_2" => 21.0, "syp_2" => 21.0, "df_2" => 21.0 },
        "16" => { "spf_2" => 17.83, "syp_2" => 18.75, "df_2" => 18.75 },
        "24" => { "spf_2" => 14.58, "syp_2" => 15.25, "df_2" => 15.25 }
      }
    }.freeze

    # Approximate nominal board-foot yields per linear foot of joist.
    BOARD_FEET_PER_LINEAR_FT = {
      "2x6"  => 1.0,
      "2x8"  => 1.333,
      "2x10" => 1.667,
      "2x12" => 2.0
    }.freeze

    VALID_SPACINGS = [ 12, 16, 24 ].freeze

    def initialize(room_length_ft:, room_width_ft:, joist_size: "2x10", spacing_in: 16, species: "spf_2")
      @room_length_ft = room_length_ft.to_f
      @room_width_ft = room_width_ft.to_f
      @joist_size = joist_size.to_s.downcase
      @spacing_in = spacing_in.to_i
      @species = species.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Joists span the shorter dimension; count across the longer dimension.
      span_ft = [ @room_length_ft, @room_width_ft ].min
      carry_ft = [ @room_length_ft, @room_width_ft ].max

      field_joists = (carry_ft * 12.0 / @spacing_in).ceil + 1
      total_linear_ft = field_joists * span_ft
      board_feet = total_linear_ft * BOARD_FEET_PER_LINEAR_FT[@joist_size]
      max_span = MAX_SPAN_FT.dig(@joist_size, @spacing_in.to_s, @species) || 0.0
      span_ok = span_ft <= max_span

      {
        valid: true,
        span_ft: span_ft.round(2),
        carry_ft: carry_ft.round(2),
        joist_count: field_joists,
        total_linear_ft: total_linear_ft.round(2),
        board_feet: board_feet.round(2),
        max_span_ft: max_span.round(2),
        span_ok: span_ok
      }
    end

    private

    def validate!
      @errors << "Room length must be greater than zero" unless @room_length_ft.positive?
      @errors << "Room width must be greater than zero" unless @room_width_ft.positive?
      @errors << "Joist size must be 2x6, 2x8, 2x10, or 2x12" unless MAX_SPAN_FT.key?(@joist_size)
      @errors << "Spacing must be 12, 16, or 24 inches" unless VALID_SPACINGS.include?(@spacing_in)
      @errors << "Species must be spf_2, syp_2, or df_2" unless %w[spf_2 syp_2 df_2].include?(@species)
    end
  end
end
