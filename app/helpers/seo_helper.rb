module SeoHelper
  # OG image paths per category — place images in public/images/og/
  OG_IMAGES = {
    "finance" => "/images/og/finance.png",
    "math" => "/images/og/math.png",
    "physics" => "/images/og/physics.png",
    "health" => "/images/og/health.png",
    "construction" => "/images/og/construction.png",
    "everyday" => "/images/og/everyday.png"
  }.freeze

  OG_DEFAULT_IMAGE = "/images/og/default.png"

  def default_domain
    ENV.fetch("DOMAIN", "https://calcwise.com")
  end

  def og_image_url(category = nil)
    path = OG_IMAGES[category.to_s] || OG_DEFAULT_IMAGE
    "#{default_domain}#{path}"
  end

  def set_meta_tags_for_calculator(title:, description:, url:, category:)
    set_meta_tags(
      title: title,
      description: description,
      canonical: url,
      og: {
        title: "#{title} | CalcWise",
        description: description,
        url: url,
        type: "website",
        site_name: "CalcWise",
        image: og_image_url(category)
      },
      twitter: {
        card: "summary_large_image",
        title: "#{title} | CalcWise",
        description: description,
        image: og_image_url(category)
      }
    )
  end

  def set_meta_tags_for_category(title:, description:, url:, category: nil)
    set_meta_tags(
      title: title,
      description: description,
      canonical: url,
      og: {
        title: "#{title} | CalcWise",
        description: description,
        url: url,
        type: "website",
        site_name: "CalcWise",
        image: og_image_url(category)
      },
      twitter: {
        card: "summary_large_image",
        title: "#{title} | CalcWise",
        description: description,
        image: og_image_url(category)
      }
    )
  end

  def breadcrumb_schema(items)
    schema = {
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" => items.each_with_index.map do |item, index|
        element = {
          "@type" => "ListItem",
          "position" => index + 1,
          "name" => item[:name]
        }
        element["item"] = item[:url] if item[:url]
        element
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
      "name" => "CalcWise",
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

  def article_schema(title:, description:, url:, published_at:, image: nil)
    schema = {
      "@context" => "https://schema.org",
      "@type" => "Article",
      "headline" => title,
      "description" => description,
      "url" => url,
      "datePublished" => published_at.iso8601,
      "publisher" => {
        "@type" => "Organization",
        "name" => "CalcWise",
        "url" => default_domain
      },
      "mainEntityOfPage" => {
        "@type" => "WebPage",
        "@id" => url
      }
    }
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
        "cssSelector" => css_selectors.presence || ["h1", ".calculator-results", ".faq-answer:first-of-type"]
      },
      "url" => url
    }
    tag.script(schema.to_json.html_safe, type: "application/ld+json")
  end

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
