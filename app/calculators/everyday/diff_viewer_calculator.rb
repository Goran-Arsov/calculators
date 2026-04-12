# frozen_string_literal: true

module Everyday
  class DiffViewerCalculator
    attr_reader :errors

    def initialize(text_a:, text_b:)
      @text_a = text_a.to_s
      @text_b = text_b.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      lines_a = @text_a.lines.map(&:chomp)
      lines_b = @text_b.lines.map(&:chomp)

      diff_lines = compute_diff(lines_a, lines_b)

      additions = diff_lines.count { |d| d[:type] == :added }
      deletions = diff_lines.count { |d| d[:type] == :removed }
      unchanged = diff_lines.count { |d| d[:type] == :unchanged }

      {
        valid: true,
        diff: diff_lines,
        additions: additions,
        deletions: deletions,
        unchanged: unchanged,
        total_lines: diff_lines.size
      }
    end

    private

    def validate!
      @errors << "Both text fields must be provided" if @text_a.strip.empty? && @text_b.strip.empty?
    end

    def compute_diff(lines_a, lines_b)
      # Simple line-by-line LCS-based diff
      lcs_table = build_lcs_table(lines_a, lines_b)
      backtrack_diff(lcs_table, lines_a, lines_b, lines_a.size, lines_b.size)
    end

    def build_lcs_table(lines_a, lines_b)
      m = lines_a.size
      n = lines_b.size
      table = Array.new(m + 1) { Array.new(n + 1, 0) }

      (1..m).each do |i|
        (1..n).each do |j|
          table[i][j] = if lines_a[i - 1] == lines_b[j - 1]
                          table[i - 1][j - 1] + 1
          else
                          [ table[i - 1][j], table[i][j - 1] ].max
          end
        end
      end

      table
    end

    def backtrack_diff(table, lines_a, lines_b, i, j)
      result = []

      while i > 0 || j > 0
        if i > 0 && j > 0 && lines_a[i - 1] == lines_b[j - 1]
          result.unshift({ type: :unchanged, line_a: i, line_b: j, content: lines_a[i - 1] })
          i -= 1
          j -= 1
        elsif j > 0 && (i == 0 || table[i][j - 1] >= table[i - 1][j])
          result.unshift({ type: :added, line_b: j, content: lines_b[j - 1] })
          j -= 1
        elsif i > 0
          result.unshift({ type: :removed, line_a: i, content: lines_a[i - 1] })
          i -= 1
        end
      end

      result
    end
  end
end
