module SeoHelper
  def default_domain
    ENV.fetch("DOMAIN", "https://calchammer.com")
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

  LOCALE_NAMES = Localization::TranslatableRegistry::LOCALE_NAMES
  SUPPORTED_LOCALES = Localization::TranslatableRegistry::SUPPORTED_LOCALES

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

  private def translatable_tool_page?
    Localization::TranslatableRegistry.translatable?(controller_path, params[:action])
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
