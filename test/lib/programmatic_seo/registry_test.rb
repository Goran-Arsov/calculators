require "test_helper"

class ProgrammaticSeo::RegistryTest < ActiveSupport::TestCase
  test "registry loads all pages" do
    assert ProgrammaticSeo::Registry.all_slugs.count > 0
  end

  test "registry loads hand-written pages by default" do
    # 10 hand-written bases with varying expansion counts (auto-generated disabled by default)
    assert_equal 57, ProgrammaticSeo::Registry.all_slugs.count
  end

  test "every page has required keys" do
    required = %i[slug route_name title h1 meta_description intro how_it_works faq category stimulus_controller]
    ProgrammaticSeo::Registry.all_pages.each do |page|
      required.each do |key|
        assert page.key?(key), "Page '#{page[:slug]}' is missing required key: #{key}"
      end
    end
  end

  test "every slug is unique" do
    slugs = ProgrammaticSeo::Registry.all_slugs
    assert_equal slugs.length, slugs.uniq.length, "Duplicate slugs found: #{slugs.group_by(&:itself).select { |_, v| v.size > 1 }.keys}"
  end

  test "every route_name is unique" do
    route_names = ProgrammaticSeo::Registry.all_pages.map { |p| p[:route_name] }
    assert_equal route_names.length, route_names.uniq.length, "Duplicate route_names found"
  end

  test "every page has at least 3 FAQ entries" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      assert page[:faq].length >= 3, "Page '#{page[:slug]}' has only #{page[:faq].length} FAQ entries"
    end
  end

  test "every page has at least 400 words of content" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      word_count = [
        page[:intro],
        page.dig(:how_it_works, :paragraphs)&.join(" "),
        page.dig(:example, :scenario),
        page.dig(:example, :steps)&.join(" "),
        page[:tips]&.join(" "),
        page[:faq]&.map { |f| f[:answer] }&.join(" ")
      ].compact.join(" ").split.size

      assert word_count >= 400, "Page '#{page[:slug]}' has only #{word_count} words (minimum 400)"
    end
  end

  test "find returns correct page for valid slug" do
    first_slug = ProgrammaticSeo::Registry.all_slugs.first
    page = ProgrammaticSeo::Registry.find(first_slug)
    assert_equal first_slug, page[:slug]
  end

  test "find returns nil for invalid slug" do
    assert_nil ProgrammaticSeo::Registry.find("nonexistent-slug-that-does-not-exist")
  end

  test "valid_slug? returns true for existing slug" do
    first_slug = ProgrammaticSeo::Registry.all_slugs.first
    assert ProgrammaticSeo::Registry.valid_slug?(first_slug)
  end

  test "valid_slug? returns false for nonexistent slug" do
    refute ProgrammaticSeo::Registry.valid_slug?("totally-fake-slug")
  end

  test "pages_for_category returns only that category" do
    ProgrammaticSeo::Registry.pages_for_category("everyday").each do |page|
      assert_equal "everyday", page[:category], "Page '#{page[:slug]}' has category '#{page[:category]}' but was returned for 'everyday'"
    end
  end

  test "pages_for_category returns empty for nonexistent category" do
    assert_empty ProgrammaticSeo::Registry.pages_for_category("nonexistent")
  end

  test "every related_slug references a real page" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      (page[:related_slugs] || []).each do |related|
        assert ProgrammaticSeo::Registry.valid_slug?(related),
          "Page '#{page[:slug]}' references non-existent related slug: '#{related}'"
      end
    end
  end

  test "every page has a base_calculator_path" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      assert page[:base_calculator_path].present?, "Page '#{page[:slug]}' missing base_calculator_path"
    end
  end

  test "title is not too long" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      assert page[:title].length <= 70, "Page '#{page[:slug]}' title is #{page[:title].length} chars (max 70)"
    end
  end

  test "meta_description is not too long" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      assert page[:meta_description].length <= 160, "Page '#{page[:slug]}' meta_description is #{page[:meta_description].length} chars (max 160)"
    end
  end

  test "pages_for_base returns pages for known base" do
    fuel_cost_pages = ProgrammaticSeo::Registry.pages_for_base("fuel-cost")
    assert_equal 6, fuel_cost_pages.length
    fuel_cost_pages.each do |page|
      assert_equal "fuel-cost", page[:base_key]
    end
  end

  test "all_pages returns array of page hashes" do
    pages = ProgrammaticSeo::Registry.all_pages
    assert_kind_of Array, pages
    assert pages.all? { |p| p.is_a?(Hash) }
  end

  # --- Quality scoring tests ---

  test "every page has quality_score and indexable keys" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      assert page.key?(:quality_score), "Page '#{page[:slug]}' is missing :quality_score"
      assert [ true, false ].include?(page[:indexable]), "Page '#{page[:slug]}' has invalid :indexable value"
    end
  end

  test "quality_score returns integer between 0 and 100" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      score = page[:quality_score]
      assert_kind_of Integer, score, "Page '#{page[:slug]}' quality_score is not an Integer"
      assert score >= 0 && score <= 100, "Page '#{page[:slug]}' quality_score #{score} is out of range 0-100"
    end
  end

  test "quality_score class method matches stored score" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      assert_equal page[:quality_score], ProgrammaticSeo::Registry.quality_score(page),
        "Stored quality_score for '#{page[:slug]}' does not match class method result"
    end
  end

  test "indexable? class method matches stored indexable flag" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      assert_equal page[:indexable], ProgrammaticSeo::Registry.indexable?(page),
        "Stored indexable for '#{page[:slug]}' does not match indexable? result"
    end
  end

  test "indexable is true when quality_score >= 60" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      expected = page[:quality_score] >= 60
      assert_equal expected, page[:indexable],
        "Page '#{page[:slug]}' has score #{page[:quality_score]} but indexable=#{page[:indexable]}"
    end
  end

  test "quality_score awards word count points correctly" do
    # A thin page with very few words gets no word count points (only the 5pts for no form_partial)
    thin_page = { intro: "short", how_it_works: { paragraphs: [] }, example: { steps: [] }, tips: [], faq: [], related_slugs: [] }
    assert_equal 5, ProgrammaticSeo::Registry.quality_score(thin_page)

    # A page with 400+ words should get at least 15 points for word count
    long_text = "word " * 400
    rich_page = { intro: long_text, how_it_works: { paragraphs: [] }, example: { steps: [] }, tips: [], faq: [], related_slugs: [] }
    score = ProgrammaticSeo::Registry.quality_score(rich_page)
    assert score >= 15, "400-word page should score at least 15 but got #{score}"
  end

  test "quality_score awards FAQ depth points" do
    base = { intro: "", how_it_works: { paragraphs: [] }, example: { steps: [] }, tips: [], related_slugs: [] }

    three_faqs = base.merge(faq: 3.times.map { { question: "Q?", answer: "A." } })
    five_faqs = base.merge(faq: 5.times.map { { question: "Q?", answer: "A." } })

    score_3 = ProgrammaticSeo::Registry.quality_score(three_faqs)
    score_5 = ProgrammaticSeo::Registry.quality_score(five_faqs)

    assert score_5 > score_3, "5 FAQs (#{score_5}) should score higher than 3 FAQs (#{score_3})"
  end

  test "quality_score awards form_partial points" do
    base = { intro: "", how_it_works: { paragraphs: [] }, example: { steps: [] }, tips: [], faq: [], related_slugs: [] }

    with_partial = base.merge(form_partial: "programmatic/forms/mortgage")
    without_partial = base.merge(form_partial: nil)

    score_with = ProgrammaticSeo::Registry.quality_score(with_partial)
    score_without = ProgrammaticSeo::Registry.quality_score(without_partial)

    assert score_with > score_without, "Page with form_partial (#{score_with}) should score higher than without (#{score_without})"
  end

  test "quality_score awards numeric example steps points" do
    base = { intro: "", how_it_works: { paragraphs: [] }, tips: [], faq: [], related_slugs: [] }

    with_numbers = base.merge(example: { steps: [ "Enter $350,000 as the loan amount" ] })
    without_numbers = base.merge(example: { steps: [ "Enter the loan amount" ] })

    score_with = ProgrammaticSeo::Registry.quality_score(with_numbers)
    score_without = ProgrammaticSeo::Registry.quality_score(without_numbers)

    assert score_with > score_without, "Numeric steps (#{score_with}) should score higher than non-numeric (#{score_without})"
  end

  test "quality_score awards related_slugs points" do
    base = { intro: "", how_it_works: { paragraphs: [] }, example: { steps: [] }, tips: [], faq: [] }

    three_related = base.merge(related_slugs: %w[a b c])
    one_related = base.merge(related_slugs: %w[a])
    no_related = base.merge(related_slugs: [])

    score_3 = ProgrammaticSeo::Registry.quality_score(three_related)
    score_1 = ProgrammaticSeo::Registry.quality_score(one_related)
    score_0 = ProgrammaticSeo::Registry.quality_score(no_related)

    assert score_3 > score_1, "3 related (#{score_3}) should score higher than 1 related (#{score_1})"
    assert score_1 > score_0, "1 related (#{score_1}) should score higher than 0 related (#{score_0})"
  end

  test "hand-written pages are all indexable" do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      assert page[:indexable], "Hand-written page '#{page[:slug]}' should be indexable (score: #{page[:quality_score]})"
    end
  end

  # --- lastmod_for tests ---

  test "lastmod_for returns a valid date string for a known slug" do
    first_slug = ProgrammaticSeo::Registry.all_slugs.first
    lastmod = ProgrammaticSeo::Registry.lastmod_for(first_slug)
    assert_match(/\A\d{4}-\d{2}-\d{2}\z/, lastmod, "lastmod_for should return a YYYY-MM-DD date string")
  end

  test "lastmod_for returns current date for unknown slug" do
    lastmod = ProgrammaticSeo::Registry.lastmod_for("nonexistent-slug-xyz")
    assert_equal Date.current.to_s, lastmod
  end

  test "lastmod_for returns a date based on content file mtime for hand-written pages" do
    slug = "how-much-house-on-100k-salary"
    lastmod = ProgrammaticSeo::Registry.lastmod_for(slug)
    content_file = Rails.root.join("lib", "programmatic_seo", "content", "salary_affordability.rb")
    expected = File.mtime(content_file).to_date.to_s
    assert_equal expected, lastmod, "lastmod should match the salary_affordability.rb file mtime"
  end

  # --- Salary affordability content tests ---

  test "salary affordability pages are loaded" do
    salary_pages = ProgrammaticSeo::Registry.pages_for_base("home-affordability")
    assert_equal 8, salary_pages.length, "Expected 8 salary affordability pages"
  end

  test "salary affordability pages have unique slugs" do
    salary_pages = ProgrammaticSeo::Registry.pages_for_base("home-affordability")
    slugs = salary_pages.map { |p| p[:slug] }
    assert_equal slugs.length, slugs.uniq.length
  end

  test "salary affordability pages reference home affordability calculator" do
    salary_pages = ProgrammaticSeo::Registry.pages_for_base("home-affordability")
    salary_pages.each do |page|
      assert_equal "home-affordability-calculator", page[:base_calculator_slug],
        "Page '#{page[:slug]}' should reference home-affordability-calculator"
      assert_equal :finance_home_affordability_path, page[:base_calculator_path]
    end
  end
end
