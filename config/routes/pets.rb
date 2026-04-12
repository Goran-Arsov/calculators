namespace :pets do
  get "cat-age-calculator", to: "calculators#cat_age", as: :cat_age
  get "cat-food-calculator", to: "calculators#cat_food", as: :cat_food
  get "fish-tank-size-calculator", to: "calculators#fish_tank", as: :fish_tank
  get "pet-insurance-roi-calculator", to: "calculators#pet_insurance_roi", as: :pet_insurance_roi
  get "pet-medication-dosage-calculator", to: "calculators#pet_medication_dosage", as: :pet_medication_dosage
  get "puppy-weight-predictor", to: "calculators#puppy_weight_predictor", as: :puppy_weight_predictor
  get "horse-feed-calculator", to: "calculators#horse_feed", as: :horse_feed
end
