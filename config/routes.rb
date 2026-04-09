Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Localized calculator routes (de, fr, es, pt)
  scope "/:locale", constraints: { locale: /de|fr|es|pt|mk/ } do
    scope :everyday, module: :everyday, as: nil do
      get "base64-encoder-decoder", to: "calculators#base64_encoder"
      get "url-encoder-decoder", to: "calculators#url_encoder"
      get "html-formatter-beautifier", to: "calculators#html_formatter"
      get "css-formatter-beautifier", to: "calculators#css_formatter"
      get "javascript-formatter-beautifier", to: "calculators#js_formatter"
      get "json-validator", to: "calculators#json_validator"
      get "json-to-yaml-converter", to: "calculators#json_to_yaml"
      get "curl-to-code-converter", to: "calculators#curl_to_code"
      get "json-to-typescript-generator", to: "calculators#json_to_typescript"
      get "html-to-jsx-converter", to: "calculators#html_to_jsx"
      get "hex-ascii-converter", to: "calculators#hex_ascii"
      get "http-status-code-reference", to: "calculators#http_status_reference"
      get "robots-txt-generator", to: "calculators#robots_txt"
      get "htaccess-generator", to: "calculators#htaccess_generator"
      get "regex-explainer", to: "calculators#regex_explainer"
      get "open-graph-preview", to: "calculators#og_preview"
      get "svg-to-png-converter", to: "calculators#svg_to_png"
    end

    scope :finance, module: :finance, as: nil do
      get "mortgage-calculator", to: "calculators#mortgage"
      get "compound-interest-calculator", to: "calculators#compound_interest"
      get "loan-calculator", to: "calculators#loan"
      get "investment-calculator", to: "calculators#investment"
      get "retirement-calculator", to: "calculators#retirement"
      get "invoice-generator", to: "calculators#invoice_generator"
      get "detailed-invoice-generator", to: "calculators#detailed_invoice_generator"
    end

    scope :health, module: :health, as: nil do
      get "bmi-calculator", to: "calculators#bmi"
      get "calorie-calculator", to: "calculators#calorie"
      get "body-fat-calculator", to: "calculators#body_fat"
      get "tdee-calculator", to: "calculators#tdee"
      get "macro-calculator", to: "calculators#macro"
    end
  end

  # Browse all
  get "browse", to: "browse#index", as: :browse

  # IT Tools
  get "information-technology", to: "it_tools#index", as: :it_tools

  # Admin
  get "admin/login", to: "admin/ratings#login", as: :admin_login
  post "admin/login", to: "admin/ratings#submit_login"
  delete "admin/logout", to: "admin/ratings#logout", as: :admin_logout
  get "admin/ratings", to: "admin/ratings#index", as: :admin_ratings

  # API
  namespace :api, defaults: { format: :json } do
    get "ratings/:slug", to: "ratings#show"
    post "ratings/:slug", to: "ratings#create"
  end

  # Category calculator routes (loaded from config/routes/*.rb)
  draw(:finance)
  draw(:math)
  draw(:physics)
  draw(:health)
  draw(:construction)
  draw(:everyday)

  # User-submitted calculator formulas
  resources :user_formulas, only: [ :new, :create ], path: "submit-calculator" do
    collection do
      get "thank-you", action: :thank_you
    end
  end

  # Blog
  get "blog", to: "blog#index", as: :blog
  get "blog/:slug", to: "blog#show", as: :blog_post

  # Static pages
  get "privacy-policy", to: "pages#privacy_policy", as: :privacy_policy
  get "terms-of-service", to: "pages#terms_of_service", as: :terms_of_service
  get "about", to: "pages#about", as: :about
  get "contact", to: "pages#contact", as: :contact
  post "contact", to: "contact_messages#create"
  get "disclaimer", to: "pages#disclaimer", as: :disclaimer

  # Newsletter
  post "newsletter", to: "newsletter_subscriptions#create", as: :newsletter_subscribe

  # Calculator embeds
  get "embed/:category/:slug", to: "embeds#show", as: :calculator_embed

  # SEO
  get "sitemap.xml", to: "sitemap#index", defaults: { format: :xml }
  get "sitemap-main.xml", to: "sitemap#show", defaults: { format: :xml }, as: :sitemap_main
  get "sitemap-:locale.xml", to: "sitemap#locale", defaults: { format: :xml }, constraints: { locale: /de|fr|es|pt|mk/ }, as: :sitemap_locale
  get "robots.txt", to: "robots#show", defaults: { format: :text }

  # Calculator suites - guided multi-step workflows
  scope :suites do
    get "home-buying", to: "suites#home_buying", as: :suite_home_buying
    get "fitness", to: "suites#fitness", as: :suite_fitness
    get "business-startup", to: "suites#business_startup", as: :suite_business_startup
  end

  # Comparison pages
  get "finance/15-year-vs-30-year-mortgage", to: "comparisons#mortgage_terms", as: :compare_mortgage_terms
  get "health/bmi-vs-body-fat", to: "comparisons#bmi_vs_body_fat", as: :compare_bmi_vs_body_fat
  get "finance/stocks-vs-crypto", to: "comparisons#stocks_vs_crypto", as: :compare_stocks_vs_crypto
  get "health/keto-vs-standard-macros", to: "comparisons#keto_vs_macros", as: :compare_keto_vs_macros
  get "finance/simple-vs-compound-interest", to: "comparisons#simple_vs_compound", as: :compare_simple_vs_compound

  # Programmatic SEO pages — auto-generated from ProgrammaticSeo::Registry
  ProgrammaticSeo::Registry.all_slugs.each do |slug|
    page = ProgrammaticSeo::Registry.find(slug)
    get slug, to: "programmatic#show", defaults: { programmatic_slug: slug }, as: page[:route_name]
  end

  # Category landing pages (must be last to avoid catching other routes)
  get ":category", to: "categories#show", as: :category,
      constraints: { category: /finance|math|physics|health|construction|everyday/ }

  root "home#index"
end
