require "test_helper"

class Everyday::DockerComposeGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates compose with single service" do
    result = Everyday::DockerComposeGeneratorCalculator.new(services: ["postgres"]).call
    assert_equal true, result[:valid]
    assert_includes result[:compose], "postgres:"
    assert_includes result[:compose], "postgres:16-alpine"
    assert_includes result[:compose], "5432:5432"
    assert_equal 1, result[:service_count]
  end

  test "generates compose with multiple services" do
    result = Everyday::DockerComposeGeneratorCalculator.new(services: %w[postgres redis]).call
    assert_equal true, result[:valid]
    assert_includes result[:compose], "postgres:"
    assert_includes result[:compose], "redis:"
    assert_equal 2, result[:service_count]
  end

  test "includes volumes section for services with named volumes" do
    result = Everyday::DockerComposeGeneratorCalculator.new(services: ["postgres"]).call
    assert_equal true, result[:valid]
    assert_includes result[:compose], "volumes:"
    assert_includes result[:compose], "postgres_data:"
  end

  test "includes depends_on for rails when postgres is selected" do
    result = Everyday::DockerComposeGeneratorCalculator.new(services: %w[postgres redis rails]).call
    assert_equal true, result[:valid]
    assert_includes result[:compose], "depends_on:"
  end

  test "includes healthcheck for postgres" do
    result = Everyday::DockerComposeGeneratorCalculator.new(services: ["postgres"]).call
    assert_equal true, result[:valid]
    assert_includes result[:compose], "healthcheck:"
    assert_includes result[:compose], "pg_isready"
  end

  test "filters unsupported services" do
    result = Everyday::DockerComposeGeneratorCalculator.new(services: %w[postgres unsupported_service]).call
    assert_equal true, result[:valid]
    assert_equal 1, result[:service_count]
  end

  test "handles string input for services" do
    result = Everyday::DockerComposeGeneratorCalculator.new(services: "postgres, redis").call
    assert_equal true, result[:valid]
    assert_equal 2, result[:service_count]
  end

  test "error when no services selected" do
    result = Everyday::DockerComposeGeneratorCalculator.new(services: []).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one service must be selected"
  end

  test "error when only unsupported services" do
    result = Everyday::DockerComposeGeneratorCalculator.new(services: ["nonexistent"]).call
    assert_equal false, result[:valid]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::DockerComposeGeneratorCalculator.new(services: ["postgres"])
    assert_equal [], calc.errors
  end
end
