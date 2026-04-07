# frozen_string_literal: true

module Everyday
  class RegexExplainerCalculator
    attr_reader :errors

    TOKEN_EXPLANATIONS = {
      "." => "Any character (except newline)",
      "\\d" => "Any digit (0-9)",
      "\\D" => "Any non-digit character",
      "\\w" => "Any word character (letter, digit, or underscore)",
      "\\W" => "Any non-word character",
      "\\s" => "Any whitespace character (space, tab, newline)",
      "\\S" => "Any non-whitespace character",
      "\\b" => "Word boundary",
      "\\B" => "Non-word boundary",
      "\\t" => "Tab character",
      "\\n" => "Newline character",
      "\\r" => "Carriage return",
      "^" => "Start of string (or line in multiline mode)",
      "$" => "End of string (or line in multiline mode)",
      "\\A" => "Absolute start of string",
      "\\z" => "Absolute end of string",
      "\\Z" => "End of string (before optional trailing newline)"
    }.freeze

    def initialize(pattern:)
      @pattern = pattern.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      tokens = tokenize(@pattern)

      {
        valid: true,
        tokens: tokens,
        token_count: tokens.size,
        has_groups: @pattern.include?("("),
        has_quantifiers: @pattern.match?(/[*+?]|\{\d/),
        has_anchors: @pattern.match?(/[\^$]|\\[bBAzZ]/)
      }
    end

    private

    def validate!
      @errors << "Pattern cannot be empty" if @pattern.strip.empty?
    end

    def tokenize(pattern)
      tokens = []
      i = 0

      while i < pattern.length
        char = pattern[i]

        case char
        when "\\"
          if i + 1 < pattern.length
            escaped = pattern[i..i + 1]
            explanation = TOKEN_EXPLANATIONS[escaped]
            if explanation
              tokens << { token: escaped, explanation: explanation }
            else
              tokens << { token: escaped, explanation: "Escaped literal character '#{pattern[i + 1]}'" }
            end
            i += 2
          else
            tokens << { token: "\\", explanation: "Backslash (incomplete escape)" }
            i += 1
          end

        when "["
          end_idx = find_char_class_end(pattern, i)
          char_class = pattern[i..end_idx]
          negated = char_class[1] == "^"
          inner = negated ? char_class[2..-2] : char_class[1..-2]
          prefix = negated ? "Any character NOT in" : "Any character in"
          tokens << { token: char_class, explanation: "#{prefix}: #{describe_char_class(inner)}" }
          i = end_idx + 1

        when "("
          group_info = parse_group_start(pattern, i)
          tokens << { token: group_info[:token], explanation: group_info[:explanation] }
          i += group_info[:token].length

        when ")"
          tokens << { token: ")", explanation: "End of group" }
          i += 1

        when "{"
          end_idx = pattern.index("}", i)
          if end_idx
            quantifier = pattern[i..end_idx]
            tokens << { token: quantifier, explanation: explain_quantifier(quantifier) }
            i = end_idx + 1
          else
            tokens << { token: "{", explanation: "Literal '{'" }
            i += 1
          end

        when "*"
          greedy = (i + 1 < pattern.length && pattern[i + 1] == "?") ? false : true
          if greedy
            tokens << { token: "*", explanation: "Zero or more times (greedy)" }
            i += 1
          else
            tokens << { token: "*?", explanation: "Zero or more times (lazy/non-greedy)" }
            i += 2
          end

        when "+"
          greedy = (i + 1 < pattern.length && pattern[i + 1] == "?") ? false : true
          if greedy
            tokens << { token: "+", explanation: "One or more times (greedy)" }
            i += 1
          else
            tokens << { token: "+?", explanation: "One or more times (lazy/non-greedy)" }
            i += 2
          end

        when "?"
          tokens << { token: "?", explanation: "Optional (zero or one time)" }
          i += 1

        when "|"
          tokens << { token: "|", explanation: "OR — match either the expression before or after" }
          i += 1

        when "^"
          tokens << { token: "^", explanation: TOKEN_EXPLANATIONS["^"] }
          i += 1

        when "$"
          tokens << { token: "$", explanation: TOKEN_EXPLANATIONS["$"] }
          i += 1

        when "."
          tokens << { token: ".", explanation: TOKEN_EXPLANATIONS["."] }
          i += 1

        else
          tokens << { token: char, explanation: "Literal character '#{char}'" }
          i += 1
        end
      end

      tokens
    end

    def find_char_class_end(pattern, start)
      i = start + 1
      i += 1 if i < pattern.length && pattern[i] == "^"
      i += 1 if i < pattern.length && pattern[i] == "]"
      while i < pattern.length
        return i if pattern[i] == "]"
        i += 1 if pattern[i] == "\\"
        i += 1
      end
      pattern.length - 1
    end

    def describe_char_class(inner)
      descriptions = []
      inner.scan(/.-.|\\.|./).each do |part|
        if part.length == 3 && part[1] == "-"
          descriptions << "'#{part[0]}' to '#{part[2]}'"
        elsif part.start_with?("\\")
          desc = TOKEN_EXPLANATIONS[part]
          descriptions << (desc || "'#{part[1]}'")
        else
          descriptions << "'#{part}'"
        end
      end
      descriptions.join(", ")
    end

    def parse_group_start(pattern, i)
      if pattern[i + 1] == "?"
        case pattern[i + 2]
        when ":"
          { token: "(?:", explanation: "Non-capturing group — groups without creating a backreference" }
        when "="
          { token: "(?=", explanation: "Positive lookahead — matches if followed by the pattern" }
        when "!"
          { token: "(?!", explanation: "Negative lookahead — matches if NOT followed by the pattern" }
        when "<"
          if pattern[i + 3] == "="
            { token: "(?<=", explanation: "Positive lookbehind — matches if preceded by the pattern" }
          elsif pattern[i + 3] == "!"
            { token: "(?<!", explanation: "Negative lookbehind — matches if NOT preceded by the pattern" }
          else
            name_end = pattern.index(">", i + 3)
            name = name_end ? pattern[i + 3...name_end] : "?"
            { token: "(?<#{name}>", explanation: "Named capturing group '#{name}'" }
          end
        else
          { token: "(", explanation: "Capturing group" }
        end
      else
        { token: "(", explanation: "Capturing group" }
      end
    end

    def explain_quantifier(q)
      inner = q[1..-2]
      if inner.include?(",")
        parts = inner.split(",", 2).map(&:strip)
        if parts[1].empty?
          "#{parts[0]} or more times"
        else
          "Between #{parts[0]} and #{parts[1]} times"
        end
      else
        "Exactly #{inner.strip} times"
      end
    end
  end
end
