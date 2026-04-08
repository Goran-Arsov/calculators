require "test_helper"

class Everyday::FakeDataGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates records with specified count" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 5, fields: [ "first_name" ]).call
    assert result[:valid]
    assert_equal 5, result[:count]
    assert_equal 5, result[:records].length
  end

  test "generates records with multiple fields" do
    fields = %w[first_name last_name email]
    result = Everyday::FakeDataGeneratorCalculator.new(count: 3, fields: fields).call
    assert result[:valid]
    assert_equal 3, result[:fields].length
    result[:records].each do |record|
      assert record.key?("first_name")
      assert record.key?("last_name")
      assert record.key?("email")
    end
  end

  test "generates valid email format" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 10, fields: [ "email" ]).call
    assert result[:valid]
    result[:records].each do |record|
      assert_match(/@/, record["email"])
      assert_match(/\./, record["email"])
    end
  end

  test "generates valid phone format" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 5, fields: [ "phone" ]).call
    assert result[:valid]
    result[:records].each do |record|
      assert_match(/\+1-\d{3}-\d{3}-\d{4}/, record["phone"])
    end
  end

  test "generates valid uuid format" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 5, fields: [ "uuid" ]).call
    assert result[:valid]
    result[:records].each do |record|
      assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/, record["uuid"])
    end
  end

  test "generates valid ip address format" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 5, fields: [ "ip_address" ]).call
    assert result[:valid]
    result[:records].each do |record|
      parts = record["ip_address"].split(".")
      assert_equal 4, parts.length
      parts.each { |p| assert (0..255).include?(p.to_i) }
    end
  end

  test "generates valid date format" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 5, fields: [ "date" ]).call
    assert result[:valid]
    result[:records].each do |record|
      assert_match(/\A\d{4}-\d{2}-\d{2}\z/, record["date"])
    end
  end

  test "generates valid url format" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 5, fields: [ "url" ]).call
    assert result[:valid]
    result[:records].each do |record|
      assert record["url"].start_with?("https://")
    end
  end

  test "generates full name from first and last" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 5, fields: %w[first_name last_name full_name]).call
    assert result[:valid]
    result[:records].each do |record|
      assert record["full_name"].include?(" ")
    end
  end

  test "generates password with 16 characters" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 5, fields: [ "password" ]).call
    assert result[:valid]
    result[:records].each do |record|
      assert_equal 16, record["password"].length
    end
  end

  test "returns error for count below minimum" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 0, fields: [ "first_name" ]).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Count must be") }
  end

  test "returns error for count above maximum" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 101, fields: [ "first_name" ]).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Count must be") }
  end

  test "returns error for empty fields" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 5, fields: []).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("At least one field") }
  end

  test "ignores unsupported field types" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 1, fields: %w[first_name invalid_field]).call
    assert result[:valid]
    assert_equal [ "first_name" ], result[:fields]
  end

  test "returns error when all fields are unsupported" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 1, fields: [ "nonexistent" ]).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("At least one field") }
  end

  test "generates all 16 supported field types" do
    fields = Everyday::FakeDataGeneratorCalculator::SUPPORTED_FIELDS
    result = Everyday::FakeDataGeneratorCalculator.new(count: 1, fields: fields).call
    assert result[:valid]
    assert_equal fields.length, result[:records].first.keys.length
  end

  test "generates exactly one record" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 1, fields: [ "first_name" ]).call
    assert result[:valid]
    assert_equal 1, result[:records].length
  end

  test "generates exactly 100 records" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 100, fields: [ "first_name" ]).call
    assert result[:valid]
    assert_equal 100, result[:records].length
  end

  test "first names come from built-in list" do
    result = Everyday::FakeDataGeneratorCalculator.new(count: 50, fields: [ "first_name" ]).call
    assert result[:valid]
    result[:records].each do |record|
      assert_includes Everyday::FakeDataGeneratorCalculator::FIRST_NAMES, record["first_name"]
    end
  end
end
