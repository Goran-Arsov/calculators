require "test_helper"

class ProgrammaticSeo::RegistryTest < ActiveSupport::TestCase
  test "registry loads all pages" do
    assert ProgrammaticSeo::Registry.all_slugs.count > 0
  end

  test "registry loads hand-written pages by default" do
    # 9 hand-written bases with varying expansion counts (auto-generated disabled by default)
    assert_equal 49, ProgrammaticSeo::Registry.all_slugs.count
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
end
