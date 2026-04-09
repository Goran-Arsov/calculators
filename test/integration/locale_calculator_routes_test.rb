require "test_helper"

class LocaleCalculatorRoutesTest < ActionDispatch::IntegrationTest
  LOCALES = %w[de fr es pt].freeze

  FINANCE_SLUGS = {
    "mortgage-calculator" => "mortgage",
    "compound-interest-calculator" => "compound_interest",
    "loan-calculator" => "loan",
    "investment-calculator" => "investment",
    "retirement-calculator" => "retirement"
  }.freeze

  HEALTH_SLUGS = {
    "bmi-calculator" => "bmi",
    "calorie-calculator" => "calorie",
    "body-fat-calculator" => "body_fat",
    "tdee-calculator" => "tdee",
    "macro-calculator" => "macro"
  }.freeze

  # --- Route accessibility ---

  test "localized finance calculator routes return 200 for all locales" do
    LOCALES.each do |locale|
      FINANCE_SLUGS.each_key do |slug|
        get "/#{locale}/finance/#{slug}"
        assert_response :success, "Failed for /#{locale}/finance/#{slug}"
      end
    end
  end

  test "localized health calculator routes return 200 for all locales" do
    LOCALES.each do |locale|
      HEALTH_SLUGS.each_key do |slug|
        get "/#{locale}/health/#{slug}"
        assert_response :success, "Failed for /#{locale}/health/#{slug}"
      end
    end
  end

  # --- I18n translations ---

  test "finance calculator titles are translated for all locales" do
    LOCALES.each do |locale|
      I18n.with_locale(locale.to_sym) do
        FINANCE_SLUGS.each_value do |action|
          title = I18n.t("finance.calculators.#{action}.title")
          refute_match(/translation missing/, title,
            "Missing #{locale} translation for finance.calculators.#{action}.title")
        end
      end
    end
  end

  test "health calculator titles are translated for all locales" do
    LOCALES.each do |locale|
      I18n.with_locale(locale.to_sym) do
        HEALTH_SLUGS.each_value do |action|
          title = I18n.t("health.calculators.#{action}.title")
          refute_match(/translation missing/, title,
            "Missing #{locale} translation for health.calculators.#{action}.title")
        end
      end
    end
  end

  test "finance calculator FAQ keys are present for all locales" do
    LOCALES.each do |locale|
      I18n.with_locale(locale.to_sym) do
        FINANCE_SLUGS.each_value do |action|
          (1..5).each do |i|
            q = I18n.t("finance.calculators.#{action}.faq.q#{i}")
            a = I18n.t("finance.calculators.#{action}.faq.a#{i}")
            refute_match(/translation missing/, q,
              "Missing #{locale} FAQ q#{i} for finance.calculators.#{action}")
            refute_match(/translation missing/, a,
              "Missing #{locale} FAQ a#{i} for finance.calculators.#{action}")
          end
        end
      end
    end
  end

  test "health calculator FAQ keys are present for all locales" do
    LOCALES.each do |locale|
      I18n.with_locale(locale.to_sym) do
        HEALTH_SLUGS.each_value do |action|
          (1..5).each do |i|
            q = I18n.t("health.calculators.#{action}.faq.q#{i}")
            a = I18n.t("health.calculators.#{action}.faq.a#{i}")
            refute_match(/translation missing/, q,
              "Missing #{locale} FAQ q#{i} for health.calculators.#{action}")
            refute_match(/translation missing/, a,
              "Missing #{locale} FAQ a#{i} for health.calculators.#{action}")
          end
        end
      end
    end
  end

  # --- Locale sitemap ---

  test "locale sitemaps include finance calculator URLs" do
    LOCALES.each do |locale|
      get "/sitemap-#{locale}.xml"
      assert_response :success

      FINANCE_SLUGS.each_key do |slug|
        assert_includes response.body, "/#{locale}/finance/#{slug}",
          "Expected sitemap-#{locale}.xml to include /#{locale}/finance/#{slug}"
      end
    end
  end

  test "locale sitemaps include health calculator URLs" do
    LOCALES.each do |locale|
      get "/sitemap-#{locale}.xml"
      assert_response :success

      HEALTH_SLUGS.each_key do |slug|
        assert_includes response.body, "/#{locale}/health/#{slug}",
          "Expected sitemap-#{locale}.xml to include /#{locale}/health/#{slug}"
      end
    end
  end

  # --- Hreflang / language switcher ---

  test "localized finance pages include translated h1" do
    LOCALES.each do |locale|
      get "/#{locale}/finance/mortgage-calculator"
      assert_response :success

      title = I18n.t("finance.calculators.mortgage.h1", locale: locale.to_sym)
      assert_includes response.body, title,
        "Expected /#{locale}/finance/mortgage-calculator to include translated h1: #{title}"
    end
  end

  test "localized health pages include translated h1" do
    LOCALES.each do |locale|
      get "/#{locale}/health/bmi-calculator"
      assert_response :success

      title = I18n.t("health.calculators.bmi.h1", locale: locale.to_sym)
      assert_includes response.body, title,
        "Expected /#{locale}/health/bmi-calculator to include translated h1: #{title}"
    end
  end
end
