namespace :relationships do
  get "love-compatibility-calculator", to: "calculators#love_compatibility", as: :love_compatibility
  get "zodiac-compatibility-calculator", to: "calculators#zodiac_compatibility", as: :zodiac_compatibility
  get "age-gap-calculator", to: "calculators#age_gap", as: :age_gap
  get "when-will-i-meet-someone-calculator", to: "calculators#when_meet", as: :when_meet
  get "flames-calculator", to: "calculators#flames", as: :flames
  get "wedding-budget-planner-calculator", to: "calculators#wedding_budget", as: :wedding_budget
  get "wedding-cost-splitter", to: "calculators#wedding_splitter", as: :wedding_splitter
  get "honeymoon-savings-calculator", to: "calculators#honeymoon_savings", as: :honeymoon_savings
  get "engagement-ring-budget-calculator", to: "calculators#engagement_ring", as: :engagement_ring
  get "cost-of-raising-a-child-calculator", to: "calculators#child_cost", as: :child_cost
  get "date-night-budget-calculator", to: "calculators#date_night_budget", as: :date_night_budget
  get "anniversary-calculator", to: "calculators#anniversary", as: :anniversary
  get "dating-duration-calculator", to: "calculators#dating_duration", as: :dating_duration
  get "days-until-wedding-calculator", to: "calculators#days_until_wedding", as: :days_until_wedding
  get "relationship-milestone-calculator", to: "calculators#milestones", as: :milestones
  get "breakup-recovery-calculator", to: "calculators#breakup_recovery", as: :breakup_recovery
  get "divorce-cost-calculator", to: "calculators#divorce_cost", as: :divorce_cost
  get "alimony-calculator", to: "calculators#alimony", as: :alimony
  get "child-support-calculator", to: "calculators#child_support", as: :child_support
  get "dating-pool-calculator", to: "calculators#dating_pool", as: :dating_pool
  get "half-your-age-plus-seven-calculator", to: "calculators#half_plus_seven", as: :half_plus_seven
  get "online-dating-roi-calculator", to: "calculators#online_dating_roi", as: :online_dating_roi
end
