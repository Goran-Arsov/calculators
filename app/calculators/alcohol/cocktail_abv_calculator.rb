# frozen_string_literal: true

module Alcohol
  # Calculates the final alcohol by volume of a cocktail from up to several ingredients,
  # accounting for dilution from ice/stirring/shaking.
  #
  # Pre-dilution ABV is the volume-weighted average of each ingredient:
  #   pre_dilution_abv = sum(volume_i * abv_i) / sum(volume_i)
  #
  # Final ABV after dilution:
  #   final_abv = pre_dilution_abv * (1 / (1 + dilution_pct))
  #
  # Typical dilution figures (Cocktail Codex / Liquid Intelligence):
  #   stirred  ~ 20-25%
  #   shaken   ~ 25-30%
  #   built    ~ 0-5%
  class CocktailAbvCalculator
    attr_reader :errors

    METHOD_DILUTION = {
      "built"   => 0.00,   # built in glass, no ice melt
      "rocks"   => 0.10,   # built on the rocks
      "stirred" => 0.22,   # stirred until properly chilled
      "shaken"  => 0.28    # hard shake until frosty
    }.freeze

    DRINK_SIZES_OZ = {
      "small"  => 4.0,
      "medium" => 5.0,
      "large"  => 6.0
    }.freeze

    def initialize(ingredients:, method: "stirred")
      @ingredients = Array(ingredients)
      @method = method.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_volume = @ingredients.sum { |i| i[:volume_oz].to_f }
      total_alcohol = @ingredients.sum { |i| i[:volume_oz].to_f * (i[:abv_pct].to_f / 100.0) }
      pre_abv = (total_alcohol / total_volume) * 100.0

      dilution = METHOD_DILUTION[@method]
      final_abv = pre_abv / (1 + dilution)
      final_volume = total_volume * (1 + dilution)

      standard_drinks_us = (final_volume * 29.5735 * (final_abv / 100.0) * 0.789) / 14.0

      {
        valid: true,
        pre_dilution_abv: pre_abv.round(2),
        final_abv: final_abv.round(2),
        dilution_pct: (dilution * 100).round(0),
        ingredient_volume_oz: total_volume.round(2),
        final_volume_oz: final_volume.round(2),
        final_volume_ml: (final_volume * 29.5735).round(1),
        standard_drinks_us: standard_drinks_us.round(2),
        strength_category: strength_category(final_abv)
      }
    end

    private

    def strength_category(abv)
      case abv
      when 0...8 then "Light (low ABV, session-style)"
      when 8...14 then "Medium (most classic cocktails)"
      when 14...22 then "Strong (Manhattan, Negroni, Old Fashioned)"
      when 22...30 then "Very strong (martinis, spirit-forward)"
      else "Extreme (neat spirit territory)"
      end
    end

    def validate!
      @errors << "Mixing method must be one of: #{METHOD_DILUTION.keys.join(', ')}" unless METHOD_DILUTION.key?(@method)
      @errors << "At least one ingredient is required" if @ingredients.empty?

      @ingredients.each_with_index do |ing, i|
        @errors << "Ingredient ##{i + 1}: volume must be positive" unless ing[:volume_oz].to_f.positive?
        @errors << "Ingredient ##{i + 1}: ABV must be between 0 and 100" unless ing[:abv_pct].to_f.between?(0, 100)
      end
    end
  end
end
