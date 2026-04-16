# frozen_string_literal: true

class CalculatorRegistry
  PETS_CALCULATORS = [
    { name: "Cat Age Calculator", slug: "cat-age-calculator", path: :pets_cat_age_path, description: "Convert your cat's age to human years using the veterinary-standard formula accounting for rapid early maturation.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Cat Food Calculator", slug: "cat-food-calculator", path: :pets_cat_food_path, description: "Calculate daily calories and food portions for your cat based on weight, age, activity level, and indoor/outdoor lifestyle.", icon_path: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Fish Tank Size Calculator", slug: "fish-tank-size-calculator", path: :pets_fish_tank_path, description: "Calculate aquarium volume, fish stocking capacity, filter requirements, and heater size for any tank shape.", icon_path: "M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" },
    { name: "Pet Insurance ROI Calculator", slug: "pet-insurance-roi-calculator", path: :pets_pet_insurance_roi_path, description: "Compare pet insurance premiums vs estimated vet bills over your pet's lifetime to see if coverage is worth it.", icon_path: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" },
    { name: "Pet Medication Dosage Calculator", slug: "pet-medication-dosage-calculator", path: :pets_pet_medication_dosage_path, description: "Calculate safe medication doses for dogs and cats by weight for common OTC medications and supplements.", icon_path: "M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" },
    { name: "Puppy Weight Predictor", slug: "puppy-weight-predictor", path: :pets_puppy_weight_predictor_path, description: "Predict your puppy's adult weight from current weight and age using breed-specific growth curves for toy to giant breeds.", icon_path: "M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" },
    { name: "Horse Feed Calculator", slug: "horse-feed-calculator", path: :pets_horse_feed_path, description: "Calculate daily hay, grain, salt, mineral supplement, and water requirements for horses based on weight and activity level.", icon_path: "M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" }
  ].freeze

end
