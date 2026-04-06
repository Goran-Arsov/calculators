require "test_helper"

class Everyday::DockerfileGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates basic Ruby Dockerfile" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "ruby").call
    assert_equal true, result[:valid]
    assert_includes result[:dockerfile], "FROM ruby:3.3"
    assert_includes result[:dockerfile], "WORKDIR /app"
    assert_includes result[:dockerfile], "COPY Gemfile Gemfile.lock"
    assert_includes result[:dockerfile], "bundle install"
    assert_includes result[:dockerfile], "EXPOSE 3000"
    assert result[:line_count] > 0
  end

  test "generates Python Dockerfile" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "python", version: "3.11").call
    assert_equal true, result[:valid]
    assert_includes result[:dockerfile], "FROM python:3.11"
    assert_includes result[:dockerfile], "requirements.txt"
    assert_includes result[:dockerfile], "pip install"
    assert_equal "3.11", result[:version]
  end

  test "generates Node.js Dockerfile" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "node").call
    assert_equal true, result[:valid]
    assert_includes result[:dockerfile], "FROM node:20"
    assert_includes result[:dockerfile], "package.json"
    assert_includes result[:dockerfile], "npm ci"
  end

  test "generates Go Dockerfile" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "go").call
    assert_equal true, result[:valid]
    assert_includes result[:dockerfile], "FROM go:1.22"
    assert_includes result[:dockerfile], "go.mod"
    assert_includes result[:dockerfile], "go mod download"
  end

  test "generates Java Dockerfile" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "java").call
    assert_equal true, result[:valid]
    assert_includes result[:dockerfile], "FROM java:21"
    assert_includes result[:dockerfile], "pom.xml"
  end

  test "generates multi-stage build" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "ruby", multi_stage: true).call
    assert_equal true, result[:valid]
    assert_includes result[:dockerfile], "AS builder"
    assert_includes result[:dockerfile], "AS production"
    assert_includes result[:dockerfile], "COPY --from=builder"
    assert_includes result[:dockerfile], "ruby:3.3-slim"
    assert_equal true, result[:multi_stage]
  end

  test "includes custom environment variables" do
    result = Everyday::DockerfileGeneratorCalculator.new(
      base_image: "node",
      env_vars: { "NODE_ENV" => "production", "PORT" => "3000" }
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:dockerfile], "ENV NODE_ENV=production"
    assert_includes result[:dockerfile], "ENV PORT=3000"
  end

  test "includes custom build steps" do
    result = Everyday::DockerfileGeneratorCalculator.new(
      base_image: "ruby",
      build_steps: [ "bundle exec rake assets:precompile", "bundle exec rake db:migrate" ]
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:dockerfile], "RUN bundle exec rake assets:precompile"
    assert_includes result[:dockerfile], "RUN bundle exec rake db:migrate"
  end

  test "custom port is used" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "node", port: 8080).call
    assert_equal true, result[:valid]
    assert_includes result[:dockerfile], "EXPOSE 8080"
    assert_equal 8080, result[:port]
  end

  test "custom command is used" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "node", command: "npm start").call
    assert_equal true, result[:valid]
    assert_includes result[:dockerfile], 'CMD ["npm", "start"]'
  end

  test "uses default version when not specified" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "ruby").call
    assert_equal "3.3", result[:version]
  end

  # --- Validation errors ---

  test "error when base image is blank" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Base image is required"
  end

  test "error when base image is unsupported" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "haskell").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported base image") }
  end

  test "error when port out of range" do
    result = Everyday::DockerfileGeneratorCalculator.new(base_image: "ruby", port: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Port") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::DockerfileGeneratorCalculator.new(base_image: "ruby")
    assert_equal [], calc.errors
  end
end
