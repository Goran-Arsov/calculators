module CalculatorHelper
  def resolve_calculator_path(calc)
    send(calc[:path])
  end

  def calculators_for_category(category_slug)
    CalculatorRegistry.calculators_for_category(category_slug)
  end

  RELATED_STOP_WORDS = %w[a an the and or for of to in is it on with from by your how what are can do].to_set.freeze

  def related_calculators(current_slug, category_slug, count: 6)
    current_calc = CalculatorRegistry.find_by_slug(current_slug)
    current_keywords = calculator_keywords(current_calc) if current_calc

    # Score same-category calculators by keyword overlap
    same_category = calculators_for_category(category_slug)
      .reject { |c| c[:slug] == current_slug }

    scored_same = score_calculators(same_category, current_keywords)

    # Include cross-category calculators to fill remaining slots
    cross_slugs = CalculatorRegistry::CROSS_CATEGORY_LINKS[current_slug] || []
    all_slugs_used = scored_same.map { |c| c[:slug] }.to_set
    all_slugs_used << current_slug

    cross_category = CalculatorRegistry.all_calculators
      .select { |c| cross_slugs.include?(c[:slug]) && !all_slugs_used.include?(c[:slug]) }

    scored_cross = score_calculators(cross_category, current_keywords)

    # Also find keyword-matched calculators from other categories
    if current_keywords&.any?
      other_category = CalculatorRegistry.all_calculators
        .reject { |c| c[:slug] == current_slug || all_slugs_used.include?(c[:slug]) || cross_slugs.include?(c[:slug]) }
        .reject { |c| same_category.any? { |sc| sc[:slug] == c[:slug] } }

      scored_other = score_calculators(other_category, current_keywords)
        .select { |c| c[:_relevance_score] > 1 } # Require at least 2 keyword matches for cross-category
    else
      scored_other = []
    end

    # Merge: prioritize same-category, then explicit cross-category links, then keyword-matched others
    results = []
    results.concat(scored_same.first(count))
    results.concat(scored_cross) if results.size < count
    results.concat(scored_other) if results.size < count

    results
      .uniq { |c| c[:slug] }
      .first(count)
      .map { |c| c.except(:_relevance_score).merge(path: resolve_calculator_path(c)) }
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
    if slugs.any?
      BlogPost.published.where(slug: slugs).limit(limit)
    else
      # Fallback: match blog posts by calculator's category
      category = calc_category_from_slug(calculator_slug)
      if category
        BlogPost.published.by_category(category).recent.limit(limit)
      else
        BlogPost.published.recent.limit(limit)
      end
    end
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
    %(<iframe src="#{url}" width="#{width}" height="#{height}" frameborder="0" style="border:none;border-radius:12px;" loading="lazy" title="Calc Hammer Calculator"></iframe>)
  end

  def embed_script_for(category_slug, calculator_slug)
    domain = ENV.fetch("DOMAIN", "https://calchammer.com")
    %(<script src="#{domain}/embed.js" data-calculator="#{calculator_slug}" data-category="#{category_slug}"></script>)
  end

  private

  # Extracts meaningful keywords from a calculator's name and description,
  # filtering out stop words and very short tokens.
  def calculator_keywords(calc)
    text = "#{calc[:name]} #{calc[:description]}"
    text.downcase.scan(/[a-z]+/).reject { |w| RELATED_STOP_WORDS.include?(w) || w.length < 3 }.to_set
  end

  # Scores and sorts calculators by keyword overlap with the current calculator.
  # Returns a deterministic ordering: highest score first, then alphabetical by slug.
  # Attaches a temporary :_relevance_score key for downstream filtering.
  def score_calculators(calculators, current_keywords)
    return calculators.sort_by { |c| c[:slug] } unless current_keywords&.any?

    calculators.map { |calc|
      calc_keywords = calculator_keywords(calc)
      score = (current_keywords & calc_keywords).size
      calc.merge(_relevance_score: score)
    }.sort_by { |c| [ -c[:_relevance_score], c[:slug] ] }
  end

  # Finds the category slug for a given calculator slug by searching ALL_CATEGORIES.
  def calc_category_from_slug(slug)
    CalculatorRegistry::ALL_CATEGORIES.each do |cat_slug, cat|
      return cat_slug if cat[:calculators].any? { |c| c[:slug] == slug }
    end
    nil
  end
end
