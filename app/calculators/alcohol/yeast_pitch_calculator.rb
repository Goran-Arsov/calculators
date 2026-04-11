# frozen_string_literal: true

module Alcohol
  # Calculates the yeast pitch rate (billion cells), required dry yeast packs, and
  # liquid starter volume for a given batch.
  #
  # Standard pitch rates from Chris White / White Labs:
  #   Ale:                0.75 million cells / mL / °P
  #   Lager:              1.5  million cells / mL / °P
  #   High-gravity ale:   1.0  million cells / mL / °P
  #   High-gravity lager: 2.0  million cells / mL / °P
  #
  # Conversions:
  #   1 gallon = 3.78541 liters
  #   °Plato ≈ (SG - 1) * 1000 / 4
  class YeastPitchCalculator
    attr_reader :errors

    PITCH_RATES = {
      "ale" => 0.75,
      "lager" => 1.5,
      "high_gravity_ale" => 1.0,
      "high_gravity_lager" => 2.0
    }.freeze

    DRY_YEAST_CELLS_PER_GRAM = 20.0  # billion viable cells per gram of fresh dry yeast
    LIQUID_PACK_CELLS = 100.0        # billion cells per fresh 100B smack-pack/vial
    STARTER_GROWTH_FACTOR = 2.0      # ~2x growth on stirred 1.040 starter at 1L per 100B inoculation

    def initialize(batch_volume_gal:, original_gravity:, beer_type: "ale", yeast_type: "dry", yeast_age_days: 0)
      @volume_gal = batch_volume_gal.to_f
      @og = original_gravity.to_f
      @beer_type = beer_type.to_s
      @yeast_type = yeast_type.to_s
      @age_days = yeast_age_days.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      volume_ml = @volume_gal * 3785.41
      plato = (@og - 1.0) * 1000.0 / 4.0
      pitch_rate = effective_pitch_rate
      cells_needed_billion = (pitch_rate * volume_ml * plato) / 1000.0

      result = {
        valid: true,
        plato: plato.round(2),
        pitch_rate_million_per_ml_per_p: pitch_rate,
        cells_needed_billion: cells_needed_billion.round(1),
        batch_volume_l: (@volume_gal * 3.78541).round(2)
      }

      case @yeast_type
      when "dry"
        viability = dry_yeast_viability(@age_days)
        viable_cells_per_11g = DRY_YEAST_CELLS_PER_GRAM * 11 * viability
        packs = (cells_needed_billion / viable_cells_per_11g).ceil
        grams = packs * 11
        result.merge!(
          yeast_type: "dry",
          dry_yeast_packs_11g: packs,
          dry_yeast_grams: grams.round(1),
          viability_pct: (viability * 100).round(0)
        )
      when "liquid"
        viability = liquid_yeast_viability(@age_days)
        cells_per_pack = LIQUID_PACK_CELLS * viability
        packs_no_starter = (cells_needed_billion / cells_per_pack).ceil
        # 1 L starter is assumed to grow a single 100B pack to ~200B
        starter_l = (cells_needed_billion / (cells_per_pack * STARTER_GROWTH_FACTOR)).round(2)
        starter_l = 0.5 if starter_l < 0.5 && cells_needed_billion > cells_per_pack
        result.merge!(
          yeast_type: "liquid",
          liquid_packs_no_starter: packs_no_starter,
          starter_size_l_one_pack: starter_l,
          viability_pct: (viability * 100).round(0)
        )
      end

      result
    end

    private

    def effective_pitch_rate
      lager = @beer_type.include?("lager")
      high_grav = @og >= 1.06
      key = if lager && high_grav then "high_gravity_lager"
      elsif lager then "lager"
      elsif high_grav then "high_gravity_ale"
      else "ale"
      end
      PITCH_RATES[key]
    end

    # ~21% loss per month for dry yeast
    def dry_yeast_viability(age_days)
      [ 1.0 - (0.007 * age_days), 0.5 ].max
    end

    # ~21% loss per month for liquid yeast
    def liquid_yeast_viability(age_days)
      [ 1.0 - (0.007 * age_days), 0.0 ].max
    end

    def validate!
      @errors << "Batch volume must be greater than zero" unless @volume_gal.positive?
      @errors << "Original gravity must be greater than 1.000" unless @og > 1.0
      @errors << "Original gravity is unrealistically high (max 1.150)" if @og > 1.15
      @errors << "Yeast type must be 'dry' or 'liquid'" unless %w[dry liquid].include?(@yeast_type)
      @errors << "Yeast age cannot be negative" if @age_days.negative?
    end
  end
end
