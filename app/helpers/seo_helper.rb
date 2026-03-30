module SeoHelper
  def default_domain
    ENV.fetch("DOMAIN", "https://calcwise.com")
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
        site_name: "CalcWise"
      }
    )
  end

  def set_meta_tags_for_category(title:, description:, url:)
    set_meta_tags(
      title: title,
      description: description,
      canonical: url,
      og: {
        title: "#{title} | CalcWise",
        description: description,
        url: url,
        type: "website",
        site_name: "CalcWise"
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

  def calculator_schema(name:, description:, url:, category:)
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
    tag.script(schema.to_json.html_safe, type: "application/ld+json")
  end
end
