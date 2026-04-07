require "test_helper"

class Everyday::HttpStatusReferenceCalculatorTest < ActiveSupport::TestCase
  test "returns all status codes with no query" do
    result = Everyday::HttpStatusReferenceCalculator.new.call
    assert result[:valid]
    assert result[:total_count] > 50
    assert_not result[:filtered]
  end

  test "filters by status code number" do
    result = Everyday::HttpStatusReferenceCalculator.new(query: "404").call
    assert result[:valid]
    assert result[:filtered]
    assert result[:codes].key?(404)
    assert_equal "Not Found", result[:codes][404][:name]
  end

  test "filters by status name" do
    result = Everyday::HttpStatusReferenceCalculator.new(query: "not found").call
    assert result[:valid]
    assert result[:codes].key?(404)
  end

  test "filters by description text" do
    result = Everyday::HttpStatusReferenceCalculator.new(query: "teapot").call
    assert result[:valid]
    assert result[:codes].key?(418)
  end

  test "returns match count when filtered" do
    result = Everyday::HttpStatusReferenceCalculator.new(query: "200").call
    assert result[:valid]
    assert result[:match_count].positive?
  end

  test "returns categories" do
    result = Everyday::HttpStatusReferenceCalculator.new.call
    assert result[:valid]
    assert_equal "Informational", result[:categories]["1xx"]
    assert_equal "Success", result[:categories]["2xx"]
    assert_equal "Server Error", result[:categories]["5xx"]
  end

  test "handles no matches gracefully" do
    result = Everyday::HttpStatusReferenceCalculator.new(query: "zzzzzzz").call
    assert result[:valid]
    assert_equal 0, result[:match_count]
  end
end
