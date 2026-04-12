# frozen_string_literal: true

module Everyday
  class GitCommitGeneratorCalculator
    attr_reader :errors

    COMMIT_TYPES = {
      "feat" => "A new feature",
      "fix" => "A bug fix",
      "docs" => "Documentation only changes",
      "style" => "Changes that do not affect the meaning of the code",
      "refactor" => "A code change that neither fixes a bug nor adds a feature",
      "perf" => "A code change that improves performance",
      "test" => "Adding missing tests or correcting existing tests",
      "build" => "Changes that affect the build system or external dependencies",
      "ci" => "Changes to CI configuration files and scripts",
      "chore" => "Other changes that do not modify src or test files",
      "revert" => "Reverts a previous commit"
    }.freeze

    def initialize(commit_type:, scope: "", description:, body: "", breaking_change: false, breaking_description: "", issue_ref: "")
      @commit_type = commit_type.to_s.strip.downcase
      @scope = scope.to_s.strip
      @description = description.to_s.strip
      @body = body.to_s.strip
      @breaking_change = ActiveModel::Type::Boolean.new.cast(breaking_change)
      @breaking_description = breaking_description.to_s.strip
      @issue_ref = issue_ref.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      message = build_message

      {
        valid: true,
        message: message,
        commit_type: @commit_type,
        type_description: COMMIT_TYPES[@commit_type],
        is_breaking: @breaking_change,
        has_body: @body.present?,
        has_issue_ref: @issue_ref.present?
      }
    end

    private

    def validate!
      @errors << "Commit type is required" if @commit_type.empty?
      @errors << "Invalid commit type: #{@commit_type}. Valid types: #{COMMIT_TYPES.keys.join(', ')}" unless COMMIT_TYPES.key?(@commit_type)
      @errors << "Description is required" if @description.empty?
      @errors << "Description must be under 100 characters" if @description.length > 100
      @errors << "Description should not end with a period" if @description.end_with?(".")
      @errors << "Description should start with lowercase" if @description.match?(/\A[A-Z]/)
      @errors << "Breaking change description is required when marking as breaking" if @breaking_change && @breaking_description.empty?
    end

    def build_message
      lines = []

      # Header line: type(scope)!: description
      header = @commit_type
      header += "(#{@scope})" if @scope.present?
      header += "!" if @breaking_change
      header += ": #{@description}"
      lines << header

      # Body
      if @body.present?
        lines << ""
        lines << @body
      end

      # Footer
      footer_lines = []
      if @breaking_change && @breaking_description.present?
        footer_lines << "BREAKING CHANGE: #{@breaking_description}"
      end

      if @issue_ref.present?
        refs = @issue_ref.split(/[,\s]+/).map(&:strip).reject(&:empty?)
        refs.each do |ref|
          ref = "##{ref}" unless ref.start_with?("#")
          footer_lines << "Refs: #{ref}"
        end
      end

      if footer_lines.any?
        lines << ""
        lines.concat(footer_lines)
      end

      lines.join("\n")
    end
  end
end
