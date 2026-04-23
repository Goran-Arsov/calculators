# frozen_string_literal: true

# Load per-category cross-link hashes from ./cross_links/
Dir[File.join(__dir__, "cross_links", "*.rb")].sort.each { |f| require_relative f }

class CalculatorRegistry
  # Maps calculators to relevant calculators in OTHER categories (or adjacent
  # tools in the same category). The _cross_category_calculators partial shows
  # the first 3 entries in a "You Might Also Need" section on each calc page,
  # so keep the list focused on genuinely complementary tools.
  #
  # The actual per-category link tables live under
  # app/models/calculator_registry/cross_links/, one file per category.
  CROSS_CATEGORY_LINKS = [
    CrossLinks::FINANCE,
    CrossLinks::HEALTH,
    CrossLinks::MATH,
    CrossLinks::PHYSICS,
    CrossLinks::AUTOMOTIVE,
    CrossLinks::CONSTRUCTION,
    CrossLinks::EVERYDAY,
    CrossLinks::COOKING,
    CrossLinks::TEXTILE,
    CrossLinks::RELATIONSHIPS,
    CrossLinks::PHOTOGRAPHY,
    CrossLinks::EDUCATION,
    CrossLinks::ALCOHOL,
    CrossLinks::PETS,
    CrossLinks::GARDENING,
    CrossLinks::GEOGRAPHY,
    CrossLinks::IT_TOOLS
  ].reduce({}, :merge).freeze
end
