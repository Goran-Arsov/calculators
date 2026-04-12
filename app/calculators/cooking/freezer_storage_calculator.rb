# frozen_string_literal: true

module Cooking
  class FreezerStorageCalculator
    attr_reader :errors

    # Recommended freezer storage times (months) at 0 F (-18 C) per USDA/FDA
    STORAGE_DATA = {
      "beef" => {
        "steaks" => { months: 12, note: "Wrap tightly in freezer paper or vacuum seal." },
        "ground_beef" => { months: 4, note: "Use freezer bags, press flat for even freezing." },
        "roasts" => { months: 12, note: "Double wrap or vacuum seal." },
        "stew_meat" => { months: 4, note: "Freeze in portion-sized bags." }
      },
      "pork" => {
        "chops" => { months: 6, note: "Separate with parchment paper before freezing." },
        "ground_pork" => { months: 4, note: "Press flat in freezer bags." },
        "roasts" => { months: 6, note: "Wrap tightly; trim excess fat before freezing." },
        "bacon" => { months: 1, note: "High fat content causes faster rancidity. Vacuum seal for up to 3 months." },
        "sausage" => { months: 2, note: "Seasoned sausage has shorter freezer life." },
        "ham_cooked" => { months: 2, note: "Slice before freezing for easy portioning." }
      },
      "poultry" => {
        "whole_chicken" => { months: 12, note: "Remove giblets before freezing." },
        "chicken_pieces" => { months: 9, note: "Freeze in single layer first, then bag together." },
        "ground_poultry" => { months: 4, note: "Press flat in freezer bags." },
        "whole_turkey" => { months: 12, note: "Keep in original packaging, add extra wrap." },
        "cooked_poultry" => { months: 4, note: "Cool completely before freezing. Store in broth for moisture." }
      },
      "seafood" => {
        "lean_fish" => { months: 8, note: "Cod, tilapia, halibut. Vacuum seal or glaze with water." },
        "fatty_fish" => { months: 3, note: "Salmon, mackerel, tuna. Vacuum seal for best results." },
        "shrimp" => { months: 6, note: "Freeze in shell for protection. Glaze with water." },
        "shellfish" => { months: 4, note: "Clams, mussels, oysters. Freeze in their liquor." },
        "cooked_fish" => { months: 3, note: "Wrap portions individually." }
      },
      "dairy" => {
        "butter" => { months: 9, note: "Keeps well in original packaging." },
        "hard_cheese" => { months: 6, note: "May become crumbly. Best for cooking after thawing." },
        "soft_cheese" => { months: 6, note: "Texture changes; best for cooking." },
        "milk" => { months: 3, note: "Leave room for expansion. Shake well after thawing." },
        "ice_cream" => { months: 2, note: "Cover surface with plastic wrap to prevent freezer burn." }
      },
      "bread_baked_goods" => {
        "bread" => { months: 3, note: "Double bag to prevent freezer burn. Slice before freezing." },
        "muffins_rolls" => { months: 3, note: "Cool completely. Freeze individually, then bag." },
        "cake_unfrosted" => { months: 4, note: "Wrap layers individually in plastic wrap and foil." },
        "cookie_dough" => { months: 3, note: "Scoop into balls, freeze on sheet, then bag." },
        "pie_unbaked" => { months: 4, note: "Do not cut steam vents until ready to bake." },
        "pizza_dough" => { months: 3, note: "Form into balls, oil surface, wrap tightly." }
      },
      "fruits_vegetables" => {
        "berries" => { months: 12, note: "Freeze in single layer on sheet pan, then bag." },
        "blanched_vegetables" => { months: 12, note: "Blanch before freezing to preserve color and texture." },
        "corn" => { months: 12, note: "Blanch ears or cut kernels. Freeze flat in bags." },
        "tomato_sauce" => { months: 6, note: "Leave headspace for expansion." },
        "herbs" => { months: 6, note: "Freeze in ice cube trays with olive oil or water." },
        "bananas" => { months: 6, note: "Peel before freezing. Great for smoothies and baking." }
      },
      "prepared_foods" => {
        "soups_stews" => { months: 3, note: "Cool completely. Leave headspace. Label with date." },
        "casseroles" => { months: 3, note: "Freeze before or after baking." },
        "cooked_rice" => { months: 6, note: "Spread on sheet pan to cool, then bag in portions." },
        "cooked_pasta" => { months: 2, note: "Slightly undercook. Toss with oil before freezing." },
        "baby_food" => { months: 3, note: "Freeze in ice cube trays, then transfer to bags." }
      }
    }.freeze

    def initialize(food_category:, food_item:)
      @food_category = food_category.to_s.strip
      @food_item = food_item.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      data = STORAGE_DATA[@food_category][@food_item]

      {
        valid: true,
        food_category: @food_category,
        food_item: @food_item,
        months: data[:months],
        days: data[:months] * 30,
        note: data[:note],
        general_tips: general_tips
      }
    end

    def self.all_categories
      STORAGE_DATA
    end

    private

    def validate!
      unless STORAGE_DATA.key?(@food_category)
        @errors << "Unknown food category: #{@food_category}"
        return
      end
      unless STORAGE_DATA[@food_category].key?(@food_item)
        @errors << "Unknown food item: #{@food_item} in category #{@food_category}"
      end
    end

    def general_tips
      [
        "Always label packages with the food name and freezing date.",
        "Keep your freezer at 0 F (-18 C) or below.",
        "Remove as much air as possible to prevent freezer burn.",
        "Cool hot foods completely before placing in the freezer.",
        "Freeze in portion sizes you will actually use."
      ]
    end
  end
end
