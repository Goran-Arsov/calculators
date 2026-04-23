# frozen_string_literal: true

module Math
  # Numerically computes the limit of a function as x approaches a target value
  # from the left, the right, or both sides. Uses an epsilon-shrinking sampling
  # strategy for finite targets and a growing-magnitude sampling strategy for
  # +/- infinity targets.
  class LimitCalculator
    APPROACH_DIRECTIONS = %w[both left right].freeze
    EPSILON_START = 1e-2
    EPSILON_MIN = 1e-12
    EPSILON_FACTOR = 0.1
    INFINITY_PROBE_MAGNITUDES = [ 1e2, 1e4, 1e6, 1e8, 1e10 ].freeze
    CONVERGENCE_SAMPLE_SIZE = 3
    CLOSE_ENOUGH_TOLERANCE = 1e-6

    attr_reader :errors

    def initialize(expression:, approach_value:, direction: "both")
      @expression = expression.to_s.strip
      @approach_value = approach_value.to_s.strip
      @direction = direction.to_s.strip.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      target = parse_approach_value(@approach_value)
      ast = Parser.new(@expression).parse

      left_limit = compute_side(ast, target, :left) if side_needed?(:left)
      right_limit = compute_side(ast, target, :right) if side_needed?(:right)

      ResultBuilder.call(
        expression: @expression,
        approach_value: @approach_value,
        direction: @direction,
        left_limit: left_limit,
        right_limit: right_limit
      )
    rescue ParseError => e
      @errors << "Invalid expression: #{e.message}"
      { valid: false, errors: @errors }
    rescue MathError => e
      @errors << e.message
      { valid: false, errors: @errors }
    end

    private

    def validate!
      @errors << "Expression cannot be blank" if @expression.empty?
      @errors << "Approach value cannot be blank" if @approach_value.empty?
      @errors << "Direction must be 'both', 'left', or 'right'" unless APPROACH_DIRECTIONS.include?(@direction)
    end

    def side_needed?(side)
      @direction == "both" || @direction == side.to_s
    end

    def parse_approach_value(val)
      case val.downcase
      when "infinity", "inf", "+infinity", "+inf" then Float::INFINITY
      when "-infinity", "-inf" then -Float::INFINITY
      when "pi" then ::Math::PI
      when "e" then ::Math::E
      else val.to_f
      end
    end

    def compute_side(ast, target, side)
      return compute_limit_at_infinity(ast, target) if target.infinite?

      compute_limit_near(ast, target, side)
    end

    def compute_limit_near(ast, target, side)
      values = []
      epsilon = EPSILON_START
      while epsilon >= EPSILON_MIN
        x = side == :left ? target - epsilon : target + epsilon
        val = safe_evaluate(ast, x)
        if val && val.finite?
          values << val
        elsif values.empty?
          return nil
        end
        epsilon *= EPSILON_FACTOR
      end
      converged_value(values)
    end

    def compute_limit_at_infinity(ast, target)
      sign = target > 0 ? 1.0 : -1.0
      values = INFINITY_PROBE_MAGNITUDES.filter_map do |n|
        val = safe_evaluate(ast, sign * n)
        val if val && val.finite?
      end
      return nil if values.length < CONVERGENCE_SAMPLE_SIZE

      converged_value(values)
    end

    def safe_evaluate(ast, x)
      Evaluator.evaluate(ast, x)
    rescue StandardError
      nil
    end

    def converged_value(values)
      return nil if values.empty?

      last = values.last(CONVERGENCE_SAMPLE_SIZE)
      return nil if last.length < 2

      last.all? { |v| close_enough?(v, last.last) } ? last.last : nil
    end

    def close_enough?(a, b)
      return true if a == b

      diff = (a - b).abs
      magnitude = [ a.abs, b.abs, 1.0 ].max
      diff / magnitude < CLOSE_ENOUGH_TOLERANCE
    end

    class ParseError < StandardError; end
    class MathError < StandardError; end

    class Parser
      FUNCTIONS = %w[sin cos tan asin acos atan sinh cosh tanh ln log log10 exp sqrt abs].freeze

      def initialize(input)
        @tokens = Lexer.new(input).tokenize
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
            when "x" then [ :var ]
            when "pi" then [ :num, ::Math::PI ]
            when "e" then [ :num, ::Math::E ]
            else raise ParseError, "unknown identifier '#{name}'"
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
