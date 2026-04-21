module Seo
  # Tier 4 head-term calculators — noindexed while the domain (registered
  # 2026-03-30) builds authority. These pages target queries dominated by
  # DR 80+ incumbents (Calculator.net, NerdWallet, Bankrate, WebMD,
  # Omnicalculator, WolframAlpha, FreeFormatter) and are unlikely to rank
  # on a new domain for ~2 years.
  #
  # Intent:
  # - Reduce sitewide "low-quality" signal so Tier 1/2 pages rank better.
  # - Keep pages live for users who arrive via internal nav.
  # - Exclude from sitemap so crawl budget concentrates on winnable pages.
  #
  # REVISIT: reassess quarterly once Google Search Console shows non-zero
  # impressions for any listed path, or at the 18–24 month mark
  # (Oct 2027 – Apr 2028). Remove paths from this list one-by-one as
  # they become commercially winnable; do not bulk-re-index.
  #
  # Locale variants (/de/..., /fr/..., /es/..., /pt/..., /mk/...) are
  # intentionally NOT listed — smaller-language SERPs face weaker
  # competition and may still be winnable.
  module NoindexList
    PATHS = %w[
      /finance/mortgage-calculator
      /finance/loan-calculator
      /finance/compound-interest-calculator
      /finance/investment-calculator
      /finance/retirement-calculator
      /finance/auto-loan-calculator
      /finance/personal-loan-calculator
      /finance/student-loan-calculator
      /finance/credit-card-payoff-calculator
      /finance/currency-converter
      /finance/salary-calculator
      /finance/paycheck-calculator
      /finance/tax-bracket-calculator
      /finance/savings-interest-calculator
      /finance/roi-calculator

      /health/bmi-calculator
      /health/calorie-calculator
      /health/tdee-calculator
      /health/macro-calculator
      /health/body-fat-calculator
      /health/ideal-weight-calculator
      /health/pregnancy-due-date-calculator
      /health/ovulation-calculator
      /health/water-intake-calculator
      /health/sleep-calculator

      /math/percentage-calculator
      /math/fraction-calculator
      /math/scientific-calculator
      /math/quadratic-equation-calculator
      /math/pythagorean-theorem-calculator
      /math/area-calculator
      /math/circumference-calculator
      /math/exponent-calculator
      /math/gcd-lcm-calculator
      /math/standard-deviation-calculator

      /automotive/mpg-calculator

      /everyday/tip-calculator
      /everyday/age-calculator
      /everyday/discount-calculator
      /everyday/date-difference-calculator
      /everyday/gas-mileage-calculator

      /construction/paint-calculator
      /construction/concrete-calculator
      /construction/flooring-calculator
      /construction/deck-calculator
      /construction/roofing-calculator
      /construction/tile-calculator

      /everyday/json-formatter
      /everyday/regex-tester
      /everyday/base64-encoder-decoder
      /everyday/uuid-generator
      /everyday/hash-generator
      /everyday/password-generator
      /everyday/lorem-ipsum-generator
    ].freeze

    PATH_SET = PATHS.to_set

    def self.include?(path)
      PATH_SET.include?(path)
    end
  end
end
