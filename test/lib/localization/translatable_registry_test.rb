require "test_helper"

class Localization::TranslatableRegistryTest < ActiveSupport::TestCase
  # These tests guard the invariant that TranslatableRegistry::ENTRIES
  # agrees with the actual `scope "/:locale"` block in config/routes.rb.
  # If either side changes, update the other to match — otherwise
  # hreflang tags point to 404s and Search Console flags them as errors.

  LOCALIZED_ROUTE_CONTROLLERS = %w[everyday/calculators finance/calculators health/calculators].freeze

  test "every registry entry has a matching locale-scoped route" do
    locale_routes = collect_locale_routes

    Localization::TranslatableRegistry.all_entries.each do |entry|
      match = locale_routes.find do |r|
        r[:controller] == entry[:controller_path] &&
          r[:action] == entry[:action] &&
          r[:slug] == entry[:slug]
      end

      assert match,
        "registry entry #{entry.inspect} has no matching /:locale route in config/routes.rb"
    end
  end

  test "every locale-scoped route has a matching registry entry" do
    locale_routes = collect_locale_routes

    locale_routes.each do |route|
      next unless LOCALIZED_ROUTE_CONTROLLERS.include?(route[:controller])

      registered_slug = Localization::TranslatableRegistry::ENTRIES
        .dig(route[:controller], route[:action])

      assert_equal route[:slug], registered_slug,
        "route #{route.inspect} is not in TranslatableRegistry::ENTRIES"
    end
  end

  test "SUPPORTED_LOCALES matches the locale constraint in routes" do
    # The locale constraint is /de|fr|es|pt|mk/ in config/routes.rb
    assert_equal %w[de fr es pt mk].sort,
      Localization::TranslatableRegistry::SUPPORTED_LOCALES.sort
  end

  test "LOCALE_NAMES covers every SUPPORTED_LOCALE" do
    Localization::TranslatableRegistry::SUPPORTED_LOCALES.each do |locale|
      assert Localization::TranslatableRegistry::LOCALE_NAMES[locale].present?,
        "LOCALE_NAMES missing entry for #{locale}"
    end
  end

  test "translatable? returns true for known controller/action pairs" do
    assert Localization::TranslatableRegistry.translatable?("everyday/calculators", "base64_encoder")
    assert Localization::TranslatableRegistry.translatable?("finance/calculators", "mortgage")
    assert Localization::TranslatableRegistry.translatable?("health/calculators", "bmi")
  end

  test "translatable? returns false for unknown pairs, nil args, or non-translatable controllers" do
    assert_not Localization::TranslatableRegistry.translatable?("everyday/calculators", "nonexistent")
    assert_not Localization::TranslatableRegistry.translatable?("math/calculators", "derivative")
    assert_not Localization::TranslatableRegistry.translatable?(nil, "mortgage")
    assert_not Localization::TranslatableRegistry.translatable?("finance/calculators", nil)
  end

  private

  def collect_locale_routes
    Rails.application.routes.routes.filter_map do |route|
      path = route.path.spec.to_s
      next unless path.start_with?("/:locale/")

      controller = route.defaults[:controller]
      action = route.defaults[:action]
      next unless controller && action

      # Strip format suffix and leading /:locale/:scope/
      slug = path
        .sub(%r{\(\.:format\)\z}, "")
        .sub(%r{\A/:locale/[^/]+/}, "")

      { controller: controller, action: action, slug: slug }
    end
  end
end
