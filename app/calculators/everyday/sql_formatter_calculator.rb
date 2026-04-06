# frozen_string_literal: true

module Everyday
  class SqlFormatterCalculator
    attr_reader :errors

    KEYWORDS = %w[
      SELECT FROM WHERE JOIN ON AND OR INSERT UPDATE DELETE CREATE ALTER DROP
      GROUP\ BY ORDER\ BY HAVING LIMIT OFFSET UNION INTO VALUES SET AS IN NOT
      NULL IS BETWEEN LIKE EXISTS CASE WHEN THEN ELSE END LEFT RIGHT INNER
      OUTER FULL CROSS DISTINCT COUNT SUM AVG MIN MAX WITH RECURSIVE
    ].freeze

    NEWLINE_BEFORE = %w[
      SELECT FROM WHERE INNER\ JOIN LEFT\ JOIN RIGHT\ JOIN FULL\ JOIN
      CROSS\ JOIN JOIN GROUP\ BY ORDER\ BY HAVING LIMIT UNION AND OR
    ].freeze

    INDENT_KEYWORDS = %w[AND OR ON SET VALUES INTO].freeze

    def initialize(sql:)
      @sql = sql.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      formatted = format_sql(@sql)

      {
        valid: true,
        formatted: formatted,
        original: @sql,
        keyword_count: count_keywords(@sql),
        line_count: formatted.lines.count
      }
    end

    private

    def validate!
      @errors << "SQL cannot be empty" if @sql.strip.empty?
    end

    def format_sql(sql)
      # Normalize whitespace
      normalized = sql.gsub(/\s+/, " ").strip

      # Uppercase keywords (handle multi-word keywords first)
      result = uppercase_keywords(normalized)

      # Add newlines before major clauses
      result = add_newlines(result)

      # Indent sub-clauses
      result = indent_subclauses(result)

      result.strip
    end

    def uppercase_keywords(sql)
      result = sql

      # Sort keywords by length descending to handle multi-word keywords first
      sorted_keywords = KEYWORDS.sort_by { |k| -k.length }

      sorted_keywords.each do |keyword|
        # Match keyword as a whole word (not part of a larger word)
        pattern = /\b#{Regexp.escape(keyword)}\b/i
        result = result.gsub(pattern) { keyword }
      end

      result
    end

    def add_newlines(sql)
      result = sql

      # Sort by length descending to handle multi-word clauses first
      sorted_clauses = NEWLINE_BEFORE.sort_by { |k| -k.length }

      # Track which positions already have newlines to avoid breaking compound keywords
      sorted_clauses.each do |clause|
        # For standalone JOIN, avoid matching when preceded by INNER/LEFT/RIGHT/FULL/CROSS
        if clause == "JOIN"
          pattern = /(?<!\bINNER)(?<!\bLEFT)(?<!\bRIGHT)(?<!\bFULL)(?<!\bCROSS)\s+(?=JOIN\b)/i
        else
          pattern = /\s+(?=#{Regexp.escape(clause)}\b)/i
        end
        result = result.gsub(pattern, "\n")
      end

      result
    end

    def indent_subclauses(sql)
      lines = sql.split("\n")
      formatted_lines = []

      lines.each do |line|
        stripped = line.strip
        if INDENT_KEYWORDS.any? { |kw| stripped.start_with?(kw) }
          formatted_lines << "  #{stripped}"
        else
          formatted_lines << stripped
        end
      end

      formatted_lines.join("\n")
    end

    def count_keywords(sql)
      count = 0
      sorted_keywords = KEYWORDS.sort_by { |k| -k.length }

      sorted_keywords.each do |keyword|
        pattern = /\b#{Regexp.escape(keyword)}\b/i
        count += sql.scan(pattern).length
      end

      count
    end
  end
end
