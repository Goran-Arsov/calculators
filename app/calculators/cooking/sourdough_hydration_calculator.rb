# frozen_string_literal: true

module Cooking
  class SourdoughHydrationCalculator
    attr_reader :errors

    # Uses baker's percentages:
    #   Hydration % = (total water / total flour) * 100
    #   Starter is a mix of flour and water at its own hydration level.
    #
    # Inputs:
    #   total_dough_weight (g), target_hydration (%), starter_percentage (% of flour),
    #   starter_hydration (%), salt_percentage (% of flour, default 2%)

    def initialize(total_dough_weight:, target_hydration:, starter_percentage:, starter_hydration: 100, salt_percentage: 2)
      @total_dough_weight = total_dough_weight.to_f
      @target_hydration = target_hydration.to_f / 100.0
      @starter_percentage = starter_percentage.to_f / 100.0
      @starter_hydration = starter_hydration.to_f / 100.0
      @salt_percentage = salt_percentage.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Baker's percentage math:
      # Let F = total flour in final dough (from all sources)
      # Total water = F * target_hydration
      # Starter amount = F * starter_percentage
      # Starter flour = starter_amount / (1 + starter_hydration)
      # Starter water = starter_amount - starter_flour
      # Salt = F * salt_percentage
      # Total dough = F + F*target_hydration + F*salt_percentage
      # => F * (1 + target_hydration + salt_percentage) = total_dough_weight

      total_flour = @total_dough_weight / (1.0 + @target_hydration + @salt_percentage)
      total_water = total_flour * @target_hydration
      salt = total_flour * @salt_percentage

      starter_amount = total_flour * @starter_percentage
      starter_flour = starter_amount / (1.0 + @starter_hydration)
      starter_water = starter_amount - starter_flour

      added_flour = total_flour - starter_flour
      added_water = total_water - starter_water

      {
        valid: true,
        total_dough_weight: @total_dough_weight.round(0),
        target_hydration_pct: (@target_hydration * 100).round(1),
        starter_hydration_pct: (@starter_hydration * 100).round(1),
        total_flour: total_flour.round(1),
        total_water: total_water.round(1),
        starter_amount: starter_amount.round(1),
        starter_flour: starter_flour.round(1),
        starter_water: starter_water.round(1),
        added_flour: added_flour.round(1),
        added_water: added_water.round(1),
        salt: salt.round(1)
      }
    end

    private

    def validate!
      @errors << "Total dough weight must be positive" unless @total_dough_weight > 0
      @errors << "Target hydration must be between 1% and 200%" unless @target_hydration > 0 && @target_hydration <= 2.0
      @errors << "Starter percentage must be between 1% and 100%" unless @starter_percentage > 0 && @starter_percentage <= 1.0
      @errors << "Starter hydration must be between 1% and 200%" unless @starter_hydration > 0 && @starter_hydration <= 2.0
      @errors << "Salt percentage must be non-negative" if @salt_percentage < 0
    end
  end
end
