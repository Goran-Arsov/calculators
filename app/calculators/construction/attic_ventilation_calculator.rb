# frozen_string_literal: true

module Construction
  class AtticVentilationCalculator
    attr_reader :errors

    # IRC R806.2 / FHA minimum ventilation requirements:
    # - 1 sqft NFA per 150 sqft of attic floor, OR
    # - 1 sqft NFA per 300 sqft if at least half of the ventilation is high
    #   (ridge, roof) and the other half low (soffit, eave) with a vapor retarder.
    # Results converted to square inches (1 sqft NFA = 144 sq in NFA).
    RATIO_1_150 = 1.0 / 150.0
    RATIO_1_300 = 1.0 / 300.0
    SQ_IN_PER_SQFT = 144.0

    METHODS = %w[balanced_1_300 unbalanced_1_150].freeze

    def initialize(attic_sqft:, method: "balanced_1_300",
                   soffit_nfa_per_piece: 9.0, ridge_vent_nfa_per_foot: 18.0)
      @attic_sqft = attic_sqft.to_f
      @method = method.to_s
      @soffit_nfa_per_piece = soffit_nfa_per_piece.to_f
      @ridge_vent_nfa_per_foot = ridge_vent_nfa_per_foot.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      ratio = @method == "balanced_1_300" ? RATIO_1_300 : RATIO_1_150
      total_nfa_sqft = @attic_sqft * ratio
      total_nfa_sqin = total_nfa_sqft * SQ_IN_PER_SQFT
      intake_sqin = total_nfa_sqin / 2.0
      exhaust_sqin = total_nfa_sqin / 2.0
      soffit_pieces = @soffit_nfa_per_piece.positive? ? (intake_sqin / @soffit_nfa_per_piece).ceil : 0
      ridge_vent_feet = @ridge_vent_nfa_per_foot.positive? ? (exhaust_sqin / @ridge_vent_nfa_per_foot).ceil : 0

      {
        valid: true,
        method_label: @method == "balanced_1_300" ? "1:300 (balanced)" : "1:150",
        total_nfa_sqft: total_nfa_sqft.round(3),
        total_nfa_sqin: total_nfa_sqin.round(1),
        intake_nfa_sqin: intake_sqin.round(1),
        exhaust_nfa_sqin: exhaust_sqin.round(1),
        soffit_vent_pieces: soffit_pieces,
        ridge_vent_feet: ridge_vent_feet
      }
    end

    private

    def validate!
      @errors << "Attic area must be greater than zero" unless @attic_sqft.positive?
      @errors << "Method must be one of: #{METHODS.join(', ')}" unless METHODS.include?(@method)
      @errors << "Soffit NFA cannot be negative" if @soffit_nfa_per_piece.negative?
      @errors << "Ridge vent NFA cannot be negative" if @ridge_vent_nfa_per_foot.negative?
    end
  end
end
