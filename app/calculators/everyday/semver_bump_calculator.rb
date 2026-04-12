# frozen_string_literal: true

module Everyday
  class SemverBumpCalculator
    attr_reader :errors

    BUMP_TYPES = %w[major minor patch].freeze

    def initialize(current_version:, bump_type:, pre_release: "", build_metadata: "")
      @current_version = current_version.to_s.strip
      @bump_type = bump_type.to_s.strip.downcase
      @pre_release = pre_release.to_s.strip
      @build_metadata = build_metadata.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      parsed = parse_version(@current_version)
      new_version = bump_version(parsed)

      {
        valid: true,
        current_version: @current_version,
        new_version: new_version,
        bump_type: @bump_type,
        major: parsed[:major],
        minor: parsed[:minor],
        patch: parsed[:patch],
        new_major: extract_major(new_version),
        new_minor: extract_minor(new_version),
        new_patch: extract_patch(new_version)
      }
    end

    private

    def validate!
      @errors << "Current version is required" if @current_version.empty?
      @errors << "Bump type is required" if @bump_type.empty?
      @errors << "Invalid bump type: #{@bump_type}. Use: #{BUMP_TYPES.join(', ')}" unless BUMP_TYPES.include?(@bump_type)

      if @current_version.present?
        version = @current_version.sub(/\Av/i, "")
        unless version.match?(/\A\d+\.\d+\.\d+/)
          @errors << "Version must follow semver format: major.minor.patch (e.g., 1.2.3)"
        end
      end

      if @pre_release.present? && !@pre_release.match?(/\A[0-9A-Za-z\-.]+\z/)
        @errors << "Pre-release identifier must only contain alphanumeric characters, hyphens, and dots"
      end

      if @build_metadata.present? && !@build_metadata.match?(/\A[0-9A-Za-z\-.]+\z/)
        @errors << "Build metadata must only contain alphanumeric characters, hyphens, and dots"
      end
    end

    def parse_version(version_string)
      clean = version_string.sub(/\Av/i, "")
      # Strip pre-release and build metadata from current version
      core = clean.split(/[-+]/).first
      parts = core.split(".").map(&:to_i)

      {
        major: parts[0] || 0,
        minor: parts[1] || 0,
        patch: parts[2] || 0
      }
    end

    def bump_version(parsed)
      major = parsed[:major]
      minor = parsed[:minor]
      patch = parsed[:patch]

      case @bump_type
      when "major"
        major += 1
        minor = 0
        patch = 0
      when "minor"
        minor += 1
        patch = 0
      when "patch"
        patch += 1
      end

      version = "#{major}.#{minor}.#{patch}"
      version += "-#{@pre_release}" if @pre_release.present?
      version += "+#{@build_metadata}" if @build_metadata.present?
      version
    end

    def extract_major(version)
      version.split(".")[0].to_i
    end

    def extract_minor(version)
      version.split(".")[1].to_i
    end

    def extract_patch(version)
      version.split(".")[2].split(/[-+]/).first.to_i
    end
  end
end
