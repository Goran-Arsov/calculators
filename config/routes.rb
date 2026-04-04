Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Finance calculators
  namespace :finance do
    get "mortgage-calculator", to: "calculators#mortgage", as: :mortgage
    get "compound-interest-calculator", to: "calculators#compound_interest", as: :compound_interest
    get "loan-calculator", to: "calculators#loan", as: :loan
    get "investment-calculator", to: "calculators#investment", as: :investment
    get "retirement-calculator", to: "calculators#retirement", as: :retirement
    get "debt-payoff-calculator", to: "calculators#debt_payoff", as: :debt_payoff
    get "salary-calculator", to: "calculators#salary", as: :salary
    get "savings-goal-calculator", to: "calculators#savings_goal", as: :savings_goal
  end

  # Math calculators
  namespace :math do
    get "percentage-calculator", to: "calculators#percentage", as: :percentage
    get "fraction-calculator", to: "calculators#fraction", as: :fraction
    get "area-calculator", to: "calculators#area", as: :area
    get "circumference-calculator", to: "calculators#circumference", as: :circumference
    get "exponent-calculator", to: "calculators#exponent", as: :exponent
  end

  # Physics calculators
  namespace :physics do
    get "velocity-calculator", to: "calculators#velocity", as: :velocity
    get "force-calculator", to: "calculators#force", as: :force
    get "kinetic-energy-calculator", to: "calculators#kinetic_energy", as: :kinetic_energy
    get "ohms-law-calculator", to: "calculators#ohms_law", as: :ohms_law
    get "projectile-motion-calculator", to: "calculators#projectile_motion", as: :projectile_motion
    get "element-mass-calculator", to: "calculators#element_mass", as: :element_mass
    get "element-volume-calculator", to: "calculators#element_volume", as: :element_volume
    get "unit-converter", to: "calculators#unit_converter", as: :unit_converter
    get "electricity-cost-calculator", to: "calculators#electricity_cost", as: :electricity_cost
    get "wire-gauge-calculator", to: "calculators#wire_gauge", as: :wire_gauge
    get "decibel-calculator", to: "calculators#decibel", as: :decibel
    get "wavelength-frequency-calculator", to: "calculators#wavelength_frequency", as: :wavelength_frequency
  end

  # Health calculators
  namespace :health do
    get "bmi-calculator", to: "calculators#bmi", as: :bmi
    get "calorie-calculator", to: "calculators#calorie", as: :calorie
    get "body-fat-calculator", to: "calculators#body_fat", as: :body_fat
  end

  # Blog
  get "blog", to: "blog#index", as: :blog
  get "blog/:slug", to: "blog#show", as: :blog_post

  # Static pages
  get "privacy-policy", to: "pages#privacy_policy", as: :privacy_policy
  get "terms-of-service", to: "pages#terms_of_service", as: :terms_of_service
  get "about", to: "pages#about", as: :about

  # SEO
  get "sitemap.xml", to: "sitemap#show", defaults: { format: :xml }
  get "robots.txt", to: "robots#show", defaults: { format: :text }

  # Category landing pages (must be last to avoid catching other routes)
  get ":category", to: "categories#show", as: :category,
      constraints: { category: /finance|math|physics|health/ }

  root "home#index"
end
