module CalculatorHelper
  def resolve_calculator_path(calc)
    send(calc[:path])
  end

  def calculators_for_category(category_slug)
    CalculatorRegistry.calculators_for_category(category_slug)
  end

  def related_calculators(current_slug, category_slug, count: 6)
    calculators_for_category(category_slug)
      .reject { |c| c[:slug] == current_slug }
      .sample(count)
      .map { |c| c.merge(path: resolve_calculator_path(c)) }
  end

  def trending_calculators(limit = 6)
    all_calcs = CalculatorRegistry.all_calculators
    trending_data = CalculatorRating.trending(limit)

    resolved = trending_data.filter_map do |entry|
      calc = all_calcs.find { |c| c[:slug] == entry[:slug] }
      next unless calc

      calc.merge(path: resolve_calculator_path(calc))
    end

    return resolved if resolved.any?

    # Fall back to first calculators from FINANCE_CALCULATORS if no ratings exist
    CalculatorRegistry::FINANCE_CALCULATORS.first(limit).map { |c| c.merge(path: resolve_calculator_path(c)) }
  end

  def related_blog_posts(calculator_slug, limit: 3)
    slugs = CalculatorRegistry::CALCULATOR_BLOG_MAP[calculator_slug] || []
    return [] if slugs.empty?
    BlogPost.published.where(slug: slugs).limit(limit)
  end

  def all_calculators_json
    CalculatorRegistry::ALL_CATEGORIES.flat_map do |category_slug, category|
      category[:calculators].map do |calc|
        {
          name: calc[:name],
          slug: calc[:slug],
          description: calc[:description],
          category: category[:title],
          icon_path: calc[:icon_path],
          path: resolve_calculator_path(calc)
        }
      end
    end.to_json
  end

  def seasonal_calculators(count: 3)
    month = Date.current.month
    slugs = CalculatorRegistry::SEASONAL_FEATURES[month] || CalculatorRegistry::SEASONAL_FEATURES[1]
    CalculatorRegistry.all_calculators
      .select { |c| slugs.include?(c[:slug]) }
      .first(count)
      .map { |c| c.merge(path: resolve_calculator_path(c)) }
  end

  def cross_category_calculators(calculator_slug, count: 3)
    slugs = CalculatorRegistry::CROSS_CATEGORY_LINKS[calculator_slug] || []
    return [] if slugs.empty?
    CalculatorRegistry.all_calculators
      .select { |c| slugs.include?(c[:slug]) }
      .first(count)
      .map { |c| c.merge(path: resolve_calculator_path(c)) }
  end

  # Renders a reusable SVG chart container for calculator visualizations.
  # Supports donut, bar, gauge, and stacked-bar chart types.
  #
  # Usage in views:
  #   <%= chart_container("donut", id: "mortgage-breakdown") %>
  #   <%= chart_container("bar", id: "yearly-comparison", width: 400, height: 300) %>
  #   <%= chart_container("gauge", id: "bmi-gauge") %>
  def chart_container(type, id: "chart", width: 280, height: 280)
    render "shared/chart", type: type, id: id, width: width, height: height
  end

  def embed_url_for(category_slug, calculator_slug)
    calculator_embed_url(category: category_slug, slug: calculator_slug)
  rescue
    nil
  end

  def embed_code_for(category_slug, calculator_slug, width: "100%", height: "500")
    url = embed_url_for(category_slug, calculator_slug)
    return nil unless url
    %(<iframe src="#{url}" width="#{width}" height="#{height}" frameborder="0" style="border:none;border-radius:12px;" loading="lazy" title="CalcWise Calculator"></iframe>)
  end

  def embed_script_for(category_slug, calculator_slug)
    domain = ENV.fetch("DOMAIN", "https://calcwise.com")
    %(<script src="#{domain}/embed.js" data-calculator="#{calculator_slug}" data-category="#{category_slug}"></script>)
  end
end
