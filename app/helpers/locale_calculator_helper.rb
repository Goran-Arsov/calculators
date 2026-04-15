module LocaleCalculatorHelper
  # Category display names per locale for breadcrumbs
  LOCALE_HOME_NAMES = {
    "de" => "Startseite",
    "fr" => "Accueil",
    "es" => "Inicio",
    "pt" => "Inicio"
  }.freeze

  # Returns the localized "Home" breadcrumb name
  def locale_home_name
    LOCALE_HOME_NAMES[I18n.locale.to_s] || "Home"
  end

  # Sets up all SEO tags for a localized calculator page using I18n keys.
  # Usage: locale_calculator_seo("finance", "mortgage", "FinanceApplication", "mortgage")
  def locale_calculator_seo(category, calculator, schema_category, calculator_slug)
    key = "#{category}.calculators.#{calculator}"

    set_meta_tags(
      title: t("#{key}.title"),
      description: t("#{key}.description"),
      canonical: locale_canonical_url,
      og: {
        title: "#{t("#{key}.title")} | Calc Hammer",
        description: t("#{key}.description"),
        url: locale_canonical_url,
        type: "website",
        site_name: "Calc Hammer"
      }
    )
  end

  # Returns FAQ schema data for a localized calculator
  def locale_faq_data(category, calculator, count: 5)
    key = "#{category}.calculators.#{calculator}.faq"
    (1..count).map do |i|
      { question: t("#{key}.q#{i}"), answer: t("#{key}.a#{i}") }
    end
  end

  # Returns breadcrumb items for a localized calculator
  def locale_breadcrumb_items(category, calculator)
    key = "#{category}.calculators.#{calculator}"
    [
      { name: locale_home_name, url: root_url },
      { name: t("#{category}.category_name"), url: category_url(category) },
      { name: t("#{key}.breadcrumb"), url: locale_canonical_url }
    ]
  end

  # Returns visual breadcrumb items (path instead of url)
  def locale_breadcrumb_nav_items(category, calculator)
    key = "#{category}.calculators.#{calculator}"
    [
      { name: locale_home_name, url: root_path },
      { name: t("#{category}.category_name"), url: category_path(category) },
      { name: t("#{key}.breadcrumb") }
    ]
  end
end
