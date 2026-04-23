# frozen_string_literal: true

module Math
  # Computes symbolic derivatives for a subset of calculus expressions.
  # Pipeline: parse -> differentiate -> simplify -> print.
  #
  # Each stage is a small, focused class that operates on a shared array-based
  # AST. See sibling files: parser.rb, differentiator.rb, simplifier.rb, printer.rb.
  class DerivativeCalculator
    SUPPORTED_FUNCTIONS = %w[sin cos tan exp ln log sqrt].freeze

    attr_reader :errors

    def initialize(expression:, variable: "x")
      @expression = expression.to_s.strip
      @variable = variable.to_s.strip.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      ast = Parser.new(@expression, @variable).parse
      raw_derivative = Differentiator.call(ast)
      simplified = Simplifier.call(raw_derivative)

      {
        valid: true,
        expression: @expression,
        variable: @variable,
        derivative: print_ast(simplified),
        steps: [
          "Original: #{print_ast(ast)}",
          "Raw derivative: #{print_ast(raw_derivative)}",
          "Simplified: #{print_ast(simplified)}"
        ]
      }
    rescue ParseError => e
      @errors << "Invalid expression: #{e.message}"
      { valid: false, errors: @errors }
    end

    private

    def validate!
      @errors << "Expression cannot be blank" if @expression.empty?
      @errors << "Variable must be a single letter" unless @variable.match?(/\A[a-z]\z/)
    end

    def print_ast(node)
      Printer.call(node, variable: @variable)
    end

    class ParseError < StandardError; end

    class Parser
      FUNCTIONS = %w[sin cos tan exp ln log sqrt abs].freeze

      def initialize(input, variable = "x")
        @tokens = Lexer.new(input).tokenize
        @variable = variable
        @pos = 0
      end

      def parse
        node = parse_expression
        raise ParseError, "unexpected token '#{peek[:value]}'" unless peek[:type] == :eof
        node
      end

      private

      def parse_expression
        node = parse_term
        while peek[:type] == :op && %w[+ -].include?(peek[:value])
          op = consume[:value]
          right = parse_term
          node = [ :binop, op, node, right ]
        end
        node
      end

      def parse_term
        node = parse_unary
        while peek[:type] == :op && %w[* /].include?(peek[:value])
          op = consume[:value]
          right = parse_unary
          node = [ :binop, op, node, right ]
        end
        node
      end

      def parse_unary
        if peek[:type] == :op && peek[:value] == "-"
          consume
          return [ :neg, parse_unary ]
        end
        if peek[:type] == :op && peek[:value] == "+"
          consume
          return parse_unary
        end
        parse_power
      end

      def parse_power
        base = parse_primary
        if peek[:type] == :op && peek[:value] == "^"
          consume
          exponent = parse_unary
          return [ :binop, "^", base, exponent ]
        end
        base
      end

      def parse_primary
        tok = peek
        case tok[:type]
        when :number
          consume
          [ :num, tok[:value].to_f ]
        when :ident
          consume
          name = tok[:value]
          if peek[:type] == :lparen
            raise ParseError, "unknown function '#{name}'" unless FUNCTIONS.include?(name)
            consume
            arg = parse_expression
            raise ParseError, "missing closing parenthesis" unless peek[:type] == :rparen
            consume
            [ :func, name, arg ]
          else
            case name
            when @variable then [ :var ]
            when "pi" then [ :num, ::Math::PI ]
            when "e" then [ :num, ::Math::E ]
            else
              raise ParseError, "unknown identifier '#{name}'"
            end
          end
        when :lparen
          consume
          node = parse_expression
          raise ParseError, "missing closing parenthesis" unless peek[:type] == :rparen
          consume
          node
        else
          raise ParseError, "unexpected token '#{tok[:value]}'"
        end
      end

      def peek
        @tokens[@pos] || { type: :eof, value: "" }
      end

      def consume
        tok = @tokens[@pos]
        @pos += 1
        tok
      end
    end

    class Lexer
      def initialize(input)
        @input = input.downcase
        @pos = 0
      end

      def tokenize
        tokens = []
        while @pos < @input.length
          ch = @input[@pos]
          if ch == " " || ch == "\t"
            @pos += 1
          elsif ch =~ /[0-9.]/
            tokens << read_number
          elsif ch =~ /[a-z]/
            tokens << read_identifier
          elsif ch == "("
            tokens << { type: :lparen, value: "(" }
            @pos += 1
          elsif ch == ")"
            tokens << { type: :rparen, value: ")" }
            @pos += 1
          elsif "+-*/^".include?(ch)
            tokens << { type: :op, value: ch }
            @pos += 1
          else
            raise ParseError, "unexpected character '#{ch}'"
          end
        end
        tokens << { type: :eof, value: "" }
        tokens
      end

      private

      def read_number
        start = @pos
        dot_seen = false
        while @pos < @input.length && @input[@pos] =~ /[0-9.]/
          if @input[@pos] == "."
            raise ParseError, "invalid number" if dot_seen
            dot_seen = true
          end
          @pos += 1
        end
        { type: :number, value: @input[start...@pos] }
      end

      def read_identifier
        start = @pos
        while @pos < @input.length && @input[@pos] =~ /[a-z0-9_]/
          @pos += 1
        end
        { type: :ident, value: @input[start...@pos] }
      end
    end
  end
end
