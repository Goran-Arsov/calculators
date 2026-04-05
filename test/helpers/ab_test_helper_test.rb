require "test_helper"

class AbTestHelperTest < ActionView::TestCase
  include AbTestHelper

  test "ab_variant returns a or b" do
    variant = ab_variant("test_experiment")
    assert_includes %w[a b], variant
  end

  test "ab_test? returns boolean" do
    result = ab_test?("test_experiment")
    assert_includes [true, false], result
  end

  test "ab_tracking_tag returns script tag" do
    tag = ab_tracking_tag("test_experiment")
    assert_match(/experiment_impression/, tag)
    assert_match(/test_experiment/, tag)
  end
end
