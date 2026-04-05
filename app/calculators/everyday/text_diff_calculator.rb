# frozen_string_literal: true

module Everyday
  class TextDiffCalculator
    attr_reader :errors

    def initialize(text_a:, text_b:)
      @text_a = text_a.to_s
      @text_b = text_b.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      lines_a = @text_a.split("\n")
      lines_b = @text_b.split("\n")
      diff = compute_diff(lines_a, lines_b)

      additions = diff.count { |d| d[:type] == :added }
      removals = diff.count { |d| d[:type] == :removed }
      unchanged = diff.count { |d| d[:type] == :unchanged }

      {
        valid: true,
        diff: diff,
        additions: additions,
        removals: removals,
        unchanged: unchanged,
        total_lines_a: lines_a.size,
        total_lines_b: lines_b.size,
        identical: @text_a == @text_b
      }
    end

    private

    def validate!
      @errors << "Both texts cannot be empty" if @text_a.strip.empty? && @text_b.strip.empty?
    end

    def compute_diff(lines_a, lines_b)
      lcs = longest_common_subsequence(lines_a, lines_b)
      result = []
      i = 0
      j = 0
      k = 0

      while k < lcs.size
        while i < lines_a.size && lines_a[i] != lcs[k]
          result << { type: :removed, line: lines_a[i], line_number: i + 1 }
          i += 1
        end
        while j < lines_b.size && lines_b[j] != lcs[k]
          result << { type: :added, line: lines_b[j], line_number: j + 1 }
          j += 1
        end
        result << { type: :unchanged, line: lcs[k], line_number_a: i + 1, line_number_b: j + 1 }
        i += 1
        j += 1
        k += 1
      end

      while i < lines_a.size
        result << { type: :removed, line: lines_a[i], line_number: i + 1 }
        i += 1
      end
      while j < lines_b.size
        result << { type: :added, line: lines_b[j], line_number: j + 1 }
        j += 1
      end

      result
    end

    def longest_common_subsequence(a, b)
      m = a.size
      n = b.size
      dp = Array.new(m + 1) { Array.new(n + 1, 0) }

      (1..m).each do |i|
        (1..n).each do |j|
          dp[i][j] = if a[i - 1] == b[j - 1]
            dp[i - 1][j - 1] + 1
          else
            [ dp[i - 1][j], dp[i][j - 1] ].max
          end
        end
      end

      # Backtrack to find the LCS
      result = []
      i = m
      j = n
      while i > 0 && j > 0
        if a[i - 1] == b[j - 1]
          result.unshift(a[i - 1])
          i -= 1
          j -= 1
        elsif dp[i - 1][j] > dp[i][j - 1]
          i -= 1
        else
          j -= 1
        end
      end

      result
    end
  end
end
