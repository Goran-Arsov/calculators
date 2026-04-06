require "test_helper"

class Everyday::UuidGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates a single UUID v4 by default" do
    result = Everyday::UuidGeneratorCalculator.new.call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1, result[:uuids].size
    assert_equal 4, result[:version]
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/, result[:uuids].first)
  end

  test "generates multiple UUIDs" do
    result = Everyday::UuidGeneratorCalculator.new(count: 5).call
    assert_equal true, result[:valid]
    assert_equal 5, result[:uuids].size
    assert_equal 5, result[:count]
    result[:uuids].each do |uuid|
      assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/, uuid)
    end
  end

  test "generates uppercase UUIDs" do
    result = Everyday::UuidGeneratorCalculator.new(count: 1, uppercase: true).call
    assert_equal true, result[:valid]
    assert_equal true, result[:uppercase]
    assert_match(/\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/, result[:uuids].first)
  end

  test "generates lowercase UUIDs by default" do
    result = Everyday::UuidGeneratorCalculator.new(count: 1).call
    assert_equal true, result[:valid]
    assert_equal false, result[:uppercase]
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/, result[:uuids].first)
  end

  test "generates maximum 10 UUIDs" do
    result = Everyday::UuidGeneratorCalculator.new(count: 10).call
    assert_equal true, result[:valid]
    assert_equal 10, result[:uuids].size
  end

  test "returns error when count exceeds maximum" do
    result = Everyday::UuidGeneratorCalculator.new(count: 11).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Count must be between 1 and 10"
  end

  test "returns error when count is zero" do
    result = Everyday::UuidGeneratorCalculator.new(count: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Count must be between 1 and 10"
  end

  test "returns error when count is negative" do
    result = Everyday::UuidGeneratorCalculator.new(count: -1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Count must be between 1 and 10"
  end

  test "each generated UUID is unique" do
    result = Everyday::UuidGeneratorCalculator.new(count: 10).call
    assert_equal true, result[:valid]
    assert_equal result[:uuids].uniq.size, result[:uuids].size
  end

  test "UUID has correct format with 36 characters" do
    result = Everyday::UuidGeneratorCalculator.new.call
    assert_equal 36, result[:uuids].first.length
  end

  test "handles string count parameter" do
    result = Everyday::UuidGeneratorCalculator.new(count: "3").call
    assert_equal true, result[:valid]
    assert_equal 3, result[:uuids].size
  end
end
