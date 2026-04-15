module SeoHelper
  # OG image paths per category — place images in public/images/og/
  OG_IMAGES = {
    "finance" => "/images/og/finance.png",
    "math" => "/images/og/math.png",
    "physics" => "/images/og/physics.png",
    "health" => "/images/og/health.png",
    "construction" => "/images/og/construction.png",
    "textile" => "/images/og/textile.png",
    "everyday" => "/images/og/everyday.png",
    "alcohol" => "/images/og/alcohol.png",
    "geography" => "/images/og/geography.png",
    "gardening" => "/images/og/gardening.png",
    "relationships" => "/images/og/relationships.png",
    "photography" => "/images/og/photography.png",
    "cooking" => "/images/og/cooking.png",
    "pets" => "/images/og/pets.png",
    "automotive" => "/images/og/automotive.png",
    "education" => "/images/og/education.png"
  }.freeze

  OG_DEFAULT_IMAGE = "/images/og/default.png"

  def default_domain
    ENV.fetch("DOMAIN", "https://calchammer.com")
  end

  def og_image_url(category = nil)
    path = OG_IMAGES[category.to_s] || OG_DEFAULT_IMAGE
    "#{default_domain}#{path}"
  end

  def set_meta_tags_for_calculator(title:, description:, url:, category:, updated_at: nil)
    tags = {
      title: title,
      description: description,
      canonical: url,
      og: {
        title: "#{title} | Calc Hammer",
        description: description,
        url: url,
        type: "website",
        site_name: "Calc Hammer",
        image: og_image_url(category)
      },
      twitter: {
        card: "summary_large_image",
        title: "#{title} | Calc Hammer",
        description: description,
        image: og_image_url(category)
      }
    }
    tags[:article] = { modified_time: updated_at.iso8601 } if updated_at
    set_meta_tags(tags)
  end

  def set_meta_tags_for_category(title:, description:, url:, category: nil)
    set_meta_tags(
      title: title,
      description: description,
      canonical: url,
      og: {
        title: "#{title} | Calc Hammer",
        description: description,
        url: url,
        type: "website",
        site_name: "Calc Hammer",
        image: og_image_url(category)
      },
      twitter: {
        card: "summary_large_image",
        title: "#{title} | Calc Hammer",
        description: description,
        image: og_image_url(category)
      }
    )
  end

  def breadcrumb_schema(items)
    fallback_url = request.original_url
    schema = {
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" => items.each_with_index.map do |item, index|
        {
          "@type" => "ListItem",
          "position" => index + 1,
          "name" => item[:name],
          "item" => item[:url] || fallback_url
        }
      end
    }
    tag.script(schema.to_json.html_safe, type: "application/ld+json")
  end

  def faq_schema(questions)
    schema = {
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" => questions.map do |q|
        {
          "@type" => "Question",
          "name" => q[:question],
          "acceptedAnswer" => {
            "@type" => "Answer",
            "text" => q[:answer]
          }
        }
      end
    }
    tag.script(schema.to_json.html_safe, type: "application/ld+json")
  end

  def howto_schema(name:, description:, steps:, total_time: nil)
    schema = {
      "@context" => "https://schema.org",
      "@type" => "HowTo",
      "name" => name,
      "description" => description,
      "step" => steps.each_with_index.map do |step, index|
        {
          "@type" => "HowToStep",
          "position" => index + 1,
          "name" => step[:name],
          "text" => step[:text]
        }
      end
    }
    schema["totalTime"] = total_time if total_time
    tag.script(schema.to_json.html_safe, type: "application/ld+json")
  end

  def website_schema(url:, search_url:)
    schema = {
      "@context" => "https://schema.org",
      "@type" => "WebSite",
      "name" => "Calc Hammer",
      "url" => url,
      "description" => "Free online calculators for finance, math, physics, health, construction, and everyday life.",
      "potentialAction" => {
        "@type" => "SearchAction",
        "target" => {
          "@type" => "EntryPoint",
          "urlTemplate" => "#{search_url}?q={search_term_string}"
        },
        "query-input" => "required name=search_term_string"
      }
    }
    tag.script(schema.to_json.html_safe, type: "application/ld+json")
  end

  def organization_schema
    schema = {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => "Calc Hammer",
      "url" => default_domain,
      "logo" => "#{default_domain}/icon.png",
      "description" => "Free online calculators for finance, math, physics, health, construction, and everyday life.",
      "sameAs" => []
    }
    tag.script(schema.to_json.html_safe, type: "application/ld+json")
  end

  def article_schema(title:, description:, url:, published_at:, image: nil, updated_at: nil)
    schema = {
      "@context" => "https://schema.org",
      "@type" => "Article",
      "headline" => title,
      "description" => description,
      "url" => url,
      "datePublished" => published_at.iso8601,
      "author" => {
        "@type" => "Person",
        "name" => "Calc Hammer Team"
      },
      "publisher" => {
        "@type" => "Organization",
        "name" => "Calc Hammer",
        "url" => default_domain
      },
      "mainEntityOfPage" => {
        "@type" => "WebPage",
        "@id" => url
      }
    }
    schema["dateModified"] = updated_at.iso8601 if updated_at
    schema["image"] = image if image
    tag.script(schema.to_json.html_safe, type: "application/ld+json")
  end

  def calculator_schema(name:, description:, url:, category:, rating_value: nil, rating_count: nil)
    schema = {
      "@context" => "https://schema.org",
      "@type" => "SoftwareApplication",
      "name" => name,
      "description" => description,
      "url" => url,
      "applicationCategory" => category,
      "operatingSystem" => "Web",
      "offers" => {
        "@type" => "Offer",
        "price" => "0",
        "priceCurrency" => "USD"
      }
    }
    if rating_value && rating_count
      schema["aggregateRating"] = {
        "@type" => "AggregateRating",
        "ratingValue" => rating_value,
        "ratingCount" => rating_count,
        "bestRating" => "5",
        "worstRating" => "1"
      }
    end
    tag.script(schema.to_json.html_safe, type: "application/ld+json")
  end

  def speakable_schema(url:, css_selectors: [])
    schema = {
      "@context" => "https://schema.org",
      "@type" => "WebPage",
      "speakable" => {
        "@type" => "SpeakableSpecification",
        "cssSelector" => css_selectors.presence || [ "h1", ".calculator-results", ".faq-answer:first-of-type" ]
      },
      "url" => url
    }
    tag.script(schema.to_json.html_safe, type: "application/ld+json")
  end

  LOCALE_NAMES = { "de" => "Deutsch", "fr" => "Fran\u00e7ais", "es" => "Espa\u00f1ol", "pt" => "Portugu\u00eas", "mk" => "Македонски" }.freeze
  SUPPORTED_LOCALES = %w[de fr es pt mk].freeze

  def hreflang_tags
    return "" unless translatable_tool_page?

    base_path = request.path.sub(%r{\A/(de|fr|es|pt|mk)/}, "/")
    base_url = "#{request.protocol}#{request.host_with_port}"

    tags = []
    tags << tag.link(rel: "alternate", hreflang: "en", href: "#{base_url}#{base_path}")
    tags << tag.link(rel: "alternate", hreflang: "x-default", href: "#{base_url}#{base_path}")
    SUPPORTED_LOCALES.each do |locale|
      tags << tag.link(rel: "alternate", hreflang: locale, href: "#{base_url}/#{locale}#{base_path}")
    end
    safe_join(tags, "\n")
  end

  def locale_canonical_url
    "#{request.protocol}#{request.host_with_port}#{request.path}"
  end

  def language_switcher
    return "" unless translatable_tool_page?

    base_path = request.path.sub(%r{\A/(de|fr|es|pt|mk)/}, "/")
    current = params[:locale] || "en"

    links = []
    links << { locale: "en", name: "English", path: base_path, current: current == "en" }
    SUPPORTED_LOCALES.each do |locale|
      links << { locale: locale, name: LOCALE_NAMES[locale], path: "/#{locale}#{base_path}", current: current == locale }
    end
    links
  end

  TRANSLATABLE_CONTROLLER_PATHS = %w[everyday/calculators finance/calculators health/calculators].freeze

  # These lists MUST stay in sync with the localized route scopes in
  # config/routes.rb — only actions that actually have translations should
  # emit hreflang tags, otherwise Google follows the alternate links to
  # non-existent URLs and reports "Not found (404)" in Search Console.
  TRANSLATABLE_EVERYDAY_ACTIONS = %w[
    base64_encoder url_encoder html_formatter css_formatter js_formatter
    json_validator json_to_yaml curl_to_code json_to_typescript html_to_jsx
    hex_ascii http_status_reference robots_txt htaccess_generator regex_explainer
    og_preview svg_to_png
  ].freeze
  TRANSLATABLE_FINANCE_ACTIONS = %w[mortgage compound_interest loan investment retirement invoice_generator detailed_invoice_generator].freeze
  TRANSLATABLE_HEALTH_ACTIONS = %w[bmi calorie body_fat tdee macro].freeze

  private def translatable_tool_page?
    return false unless params[:action].present?

    case controller_path
    when "everyday/calculators"
      TRANSLATABLE_EVERYDAY_ACTIONS.include?(params[:action])
    when "finance/calculators"
      TRANSLATABLE_FINANCE_ACTIONS.include?(params[:action])
    when "health/calculators"
      TRANSLATABLE_HEALTH_ACTIONS.include?(params[:action])
    else
      false
    end
  end

  public

  def calculator_schema_with_ratings(name:, description:, url:, category:, calculator_slug:)
    rating = CalculatorRating.rating_for_schema(calculator_slug)
    calculator_schema(
      name: name,
      description: description,
      url: url,
      category: category,
      rating_value: rating&.dig(:rating_value),
      rating_count: rating&.dig(:rating_count)
    )
  end
end
