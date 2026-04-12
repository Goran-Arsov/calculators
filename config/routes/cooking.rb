namespace :cooking do
  get "recipe-scaler", to: "calculators#recipe_scaler", as: :recipe_scaler
  get "baking-substitution-calculator", to: "calculators#baking_substitution", as: :baking_substitution
  get "sourdough-hydration-calculator", to: "calculators#sourdough_hydration", as: :sourdough_hydration
  get "meat-cooking-time-calculator", to: "calculators#meat_cooking_time", as: :meat_cooking_time
  get "smoke-time-calculator", to: "calculators#smoke_time", as: :smoke_time
  get "pizza-dough-calculator", to: "calculators#pizza_dough", as: :pizza_dough
  get "canning-altitude-calculator", to: "calculators#canning_altitude", as: :canning_altitude
  get "freezer-storage-time-calculator", to: "calculators#freezer_storage", as: :freezer_storage
  get "meal-prep-cost-calculator", to: "calculators#meal_prep_cost", as: :meal_prep_cost
  get "macros-per-recipe-calculator", to: "calculators#macros_per_recipe", as: :macros_per_recipe
end
