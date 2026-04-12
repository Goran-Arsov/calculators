# frozen_string_literal: true

module Cooking
  class BakingSubstitutionCalculator
    attr_reader :errors

    # Conversion ratios: { from => { to => ratio } }
    # Ratio means: 1 unit of "from" = ratio units of "to"
    SUBSTITUTIONS = {
      "butter" => {
        "oil" => { ratio: 0.75, note: "Use 3/4 the amount of oil for butter." },
        "applesauce" => { ratio: 0.5, note: "Use half the amount of applesauce for butter. Reduces fat and adds moisture." },
        "coconut_oil" => { ratio: 1.0, note: "Coconut oil substitutes 1:1 for butter." },
        "margarine" => { ratio: 1.0, note: "Margarine substitutes 1:1 for butter." }
      },
      "oil" => {
        "butter" => { ratio: 1.33, note: "Use 1-1/3 the amount of butter for oil." },
        "applesauce" => { ratio: 1.0, note: "Applesauce substitutes 1:1 for oil in baking." }
      },
      "all_purpose_flour" => {
        "cake_flour" => { ratio: 1.125, note: "Use 1-1/8 cups cake flour per cup of all-purpose. Remove 2 tbsp per cup and replace with cornstarch." },
        "bread_flour" => { ratio: 1.0, note: "Bread flour substitutes 1:1 but produces chewier results." },
        "whole_wheat_flour" => { ratio: 0.75, note: "Replace only 75% to avoid dense results. Start with half whole wheat." },
        "almond_flour" => { ratio: 1.0, note: "1:1 ratio but add a binding agent (egg or xanthan gum). Results will be denser." },
        "oat_flour" => { ratio: 1.0, note: "Oat flour substitutes 1:1 for all-purpose flour." }
      },
      "white_sugar" => {
        "brown_sugar" => { ratio: 1.0, note: "Brown sugar substitutes 1:1. Pack firmly when measuring." },
        "honey" => { ratio: 0.75, note: "Use 3/4 the amount of honey. Reduce other liquids by 1/4 cup per cup of honey." },
        "maple_syrup" => { ratio: 0.75, note: "Use 3/4 the amount of maple syrup. Reduce other liquids by 3 tbsp per cup." },
        "coconut_sugar" => { ratio: 1.0, note: "Coconut sugar substitutes 1:1 for white sugar." }
      },
      "egg" => {
        "flax_egg" => { ratio: 1.0, note: "1 flax egg = 1 tbsp ground flaxseed + 3 tbsp water. Let sit 5 minutes." },
        "chia_egg" => { ratio: 1.0, note: "1 chia egg = 1 tbsp chia seeds + 3 tbsp water. Let sit 5 minutes." },
        "applesauce_egg" => { ratio: 1.0, note: "1/4 cup (60 mL) applesauce replaces 1 egg." },
        "banana" => { ratio: 1.0, note: "1/4 cup (about half a banana) mashed banana replaces 1 egg." },
        "yogurt" => { ratio: 1.0, note: "1/4 cup yogurt replaces 1 egg." }
      },
      "buttermilk" => {
        "milk_vinegar" => { ratio: 1.0, note: "1 cup milk + 1 tbsp vinegar or lemon juice. Let stand 5 minutes." },
        "milk_cream_of_tartar" => { ratio: 1.0, note: "1 cup milk + 1-3/4 tsp cream of tartar." },
        "yogurt" => { ratio: 1.0, note: "Thin yogurt with a little milk to buttermilk consistency." }
      }
    }.freeze

    def initialize(from_ingredient:, to_ingredient:, amount:)
      @from_ingredient = from_ingredient.to_s.strip
      @to_ingredient = to_ingredient.to_s.strip
      @amount = amount.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      sub = SUBSTITUTIONS[@from_ingredient][@to_ingredient]
      converted_amount = (@amount * sub[:ratio]).round(2)

      {
        valid: true,
        from_ingredient: @from_ingredient,
        to_ingredient: @to_ingredient,
        original_amount: @amount,
        converted_amount: converted_amount,
        ratio: sub[:ratio],
        note: sub[:note]
      }
    end

    def self.available_substitutions
      SUBSTITUTIONS
    end

    private

    def validate!
      @errors << "Amount must be positive" unless @amount > 0
      unless SUBSTITUTIONS.key?(@from_ingredient)
        @errors << "Unknown source ingredient: #{@from_ingredient}"
        return
      end
      unless SUBSTITUTIONS[@from_ingredient].key?(@to_ingredient)
        @errors << "No substitution available from #{@from_ingredient} to #{@to_ingredient}"
      end
    end
  end
end
