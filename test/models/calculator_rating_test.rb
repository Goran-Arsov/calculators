require "test_helper"

class CalculatorRatingTest < ActiveSupport::TestCase
  test "valid rating saves" do
    rating = CalculatorRating.new(calculator_slug: "mortgage-calculator", direction: "up", ip_hash: "abc123")
    assert rating.valid?
    assert rating.save
  end

  test "requires calculator_slug" do
    rating = CalculatorRating.new(direction: "up", ip_hash: "abc123")
    refute rating.valid?
    assert_includes rating.errors[:calculator_slug], "can't be blank"
  end

  test "requires direction" do
    rating = CalculatorRating.new(calculator_slug: "bmi-calculator", ip_hash: "abc123")
    refute rating.valid?
  end

  test "direction must be up or down" do
    rating = CalculatorRating.new(calculator_slug: "bmi-calculator", direction: "sideways", ip_hash: "abc123")
    refute rating.valid?
    assert_includes rating.errors[:direction], "is not included in the list"
  end

  test "requires ip_hash" do
    rating = CalculatorRating.new(calculator_slug: "bmi-calculator", direction: "up")
    refute rating.valid?
  end

  test "same IP cannot rate same calculator twice" do
    CalculatorRating.create!(calculator_slug: "loan-calculator", direction: "up", ip_hash: "dup123")
    duplicate = CalculatorRating.new(calculator_slug: "loan-calculator", direction: "down", ip_hash: "dup123")
    refute duplicate.valid?
  end

  test "same IP can rate different calculators" do
    CalculatorRating.create!(calculator_slug: "calc-a", direction: "up", ip_hash: "shared_ip")
    rating = CalculatorRating.new(calculator_slug: "calc-b", direction: "down", ip_hash: "shared_ip")
    assert rating.valid?
  end

  test "counts_for returns up and down counts" do
    CalculatorRating.create!(calculator_slug: "test-calc", direction: "up", ip_hash: "ip1")
    CalculatorRating.create!(calculator_slug: "test-calc", direction: "up", ip_hash: "ip2")
    CalculatorRating.create!(calculator_slug: "test-calc", direction: "down", ip_hash: "ip3")

    counts = CalculatorRating.counts_for("test-calc")
    assert_equal 2, counts[:up]
    assert_equal 1, counts[:down]
  end

  test "counts_for returns zeros for unknown slug" do
    counts = CalculatorRating.counts_for("nonexistent")
    assert_equal 0, counts[:up]
    assert_equal 0, counts[:down]
  end

  test "rating_for_schema returns nil when no ratings" do
    assert_nil CalculatorRating.rating_for_schema("empty-calc")
  end

  test "rating_for_schema returns value and count" do
    CalculatorRating.create!(calculator_slug: "schema-calc", direction: "up", ip_hash: "s1")
    CalculatorRating.create!(calculator_slug: "schema-calc", direction: "up", ip_hash: "s2")
    CalculatorRating.create!(calculator_slug: "schema-calc", direction: "up", ip_hash: "s3")
    CalculatorRating.create!(calculator_slug: "schema-calc", direction: "down", ip_hash: "s4")

    result = CalculatorRating.rating_for_schema("schema-calc")
    assert_equal 4, result[:rating_count]
    # 75% up → 0.75 * 4 + 1 = 4.0
    assert_in_delta 4.0, result[:rating_value], 0.1
  end

  test "rating_for_schema with all thumbs up gives 5.0" do
    CalculatorRating.create!(calculator_slug: "perfect-calc", direction: "up", ip_hash: "p1")
    CalculatorRating.create!(calculator_slug: "perfect-calc", direction: "up", ip_hash: "p2")

    result = CalculatorRating.rating_for_schema("perfect-calc")
    assert_in_delta 5.0, result[:rating_value], 0.1
  end

  test "scopes filter correctly" do
    CalculatorRating.create!(calculator_slug: "scope-calc", direction: "up", ip_hash: "sc1")
    CalculatorRating.create!(calculator_slug: "scope-calc", direction: "down", ip_hash: "sc2")
    CalculatorRating.create!(calculator_slug: "other-calc", direction: "up", ip_hash: "sc3")

    assert_equal 2, CalculatorRating.for_calculator("scope-calc").count
    assert_equal 1, CalculatorRating.for_calculator("scope-calc").thumbs_up.count
    assert_equal 1, CalculatorRating.for_calculator("scope-calc").thumbs_down.count
  end
end
