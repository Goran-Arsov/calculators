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

    SIMPLE_ANCHOR_CHARS = %w[^ $ .].freeze

    QUANTIFIER_EXPLANATIONS = {
      "*"  => "Zero or more times (greedy)",
      "*?" => "Zero or more times (lazy/non-greedy)",
      "+"  => "One or more times (greedy)",
      "+?" => "One or more times (lazy/non-greedy)"
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
        token, i = next_token(pattern, i)
        tokens << token
      end
      tokens
    end

    def next_token(pattern, i)
      char = pattern[i]

      case char
      when "\\" then parse_escape(pattern, i)
      when "["  then parse_char_class(pattern, i)
      when "("  then parse_group(pattern, i)
      when ")"  then [ { token: ")", explanation: "End of group" }, i + 1 ]
      when "{"  then parse_brace_quantifier(pattern, i)
      when "*"  then parse_greedy_quantifier(pattern, i, base: "*")
      when "+"  then parse_greedy_quantifier(pattern, i, base: "+")
      when "?"  then [ { token: "?", explanation: "Optional (zero or one time)" }, i + 1 ]
      when "|"  then [ { token: "|", explanation: "OR — match either the expression before or after" }, i + 1 ]
      else
        parse_simple_char(char, i)
      end
    end

    def parse_escape(pattern, i)
      return [ { token: "\\", explanation: "Backslash (incomplete escape)" }, i + 1 ] if i + 1 >= pattern.length

      escaped = pattern[i..i + 1]
      explanation = TOKEN_EXPLANATIONS[escaped] || "Escaped literal character '#{pattern[i + 1]}'"
      [ { token: escaped, explanation: explanation }, i + 2 ]
    end

    def parse_char_class(pattern, i)
      end_idx = find_char_class_end(pattern, i)
      char_class = pattern[i..end_idx]
      negated = char_class[1] == "^"
      inner = negated ? char_class[2..-2] : char_class[1..-2]
      prefix = negated ? "Any character NOT in" : "Any character in"
      [ { token: char_class, explanation: "#{prefix}: #{describe_char_class(inner)}" }, end_idx + 1 ]
    end

    def parse_group(pattern, i)
      info = group_kind(pattern, i)
      [ { token: info[:token], explanation: info[:explanation] }, i + info[:token].length ]
    end

    def parse_brace_quantifier(pattern, i)
      end_idx = pattern.index("}", i)
      return [ { token: "{", explanation: "Literal '{'" }, i + 1 ] unless end_idx

      quantifier = pattern[i..end_idx]
      [ { token: quantifier, explanation: explain_quantifier(quantifier) }, end_idx + 1 ]
    end

    def parse_greedy_quantifier(pattern, i, base:)
      lazy = pattern[i + 1] == "?"
      token = lazy ? "#{base}?" : base
      [ { token: token, explanation: QUANTIFIER_EXPLANATIONS[token] }, i + token.length ]
    end

    def parse_simple_char(char, i)
      explanation = SIMPLE_ANCHOR_CHARS.include?(char) ? TOKEN_EXPLANATIONS[char] : "Literal character '#{char}'"
      [ { token: char, explanation: explanation }, i + 1 ]
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
      descriptions = inner.scan(/.-.|\\.|./).map { |part| describe_char_class_part(part) }
      descriptions.join(", ")
    end

    def describe_char_class_part(part)
      return "'#{part[0]}' to '#{part[2]}'" if part.length == 3 && part[1] == "-"
      return (TOKEN_EXPLANATIONS[part] || "'#{part[1]}'") if part.start_with?("\\")

      "'#{part}'"
    end

    def group_kind(pattern, i)
      return { token: "(", explanation: "Capturing group" } if pattern[i + 1] != "?"

      case pattern[i + 2]
      when ":" then { token: "(?:", explanation: "Non-capturing group — groups without creating a backreference" }
      when "=" then { token: "(?=", explanation: "Positive lookahead — matches if followed by the pattern" }
      when "!" then { token: "(?!", explanation: "Negative lookahead — matches if NOT followed by the pattern" }
      when "<" then lookbehind_or_named(pattern, i)
      else          { token: "(", explanation: "Capturing group" }
      end
    end

    def lookbehind_or_named(pattern, i)
      case pattern[i + 3]
      when "=" then { token: "(?<=", explanation: "Positive lookbehind — matches if preceded by the pattern" }
      when "!" then { token: "(?<!", explanation: "Negative lookbehind — matches if NOT preceded by the pattern" }
      else
        name_end = pattern.index(">", i + 3)
        name = name_end ? pattern[i + 3...name_end] : "?"
        { token: "(?<#{name}>", explanation: "Named capturing group '#{name}'" }
      end
    end

    def explain_quantifier(q)
      inner = q[1..-2]
      return "Exactly #{inner.strip} times" unless inner.include?(",")

      min, max = inner.split(",", 2).map(&:strip)
      max.empty? ? "#{min} or more times" : "Between #{min} and #{max} times"
    end
  end
end
