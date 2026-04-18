require "test_helper"

class AbTestHelperTest < ActionView::TestCase
  include AbTestHelper

  test "ab_variant returns a or b" do
    variant = ab_variant("test_experiment")
    assert_includes %w[a b], variant
  end
end
