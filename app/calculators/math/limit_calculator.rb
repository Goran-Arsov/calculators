module Math
  class LimitCalculator
    APPROACH_DIRECTIONS = %w[both left right].freeze
    EPSILON_START = 1e-2
    EPSILON_MIN = 1e-12
    EPSILON_FACTOR = 0.1

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

      left_limit = nil
      right_limit = nil

      if @direction == "both" || @direction == "left"
        left_limit = compute_limit(ast, target, :left)
      end

      if @direction == "both" || @direction == "right"
        right_limit = compute_limit(ast, target, :right)
      end

      if @direction == "both"
        if left_limit && right_limit
          if close_enough?(left_limit, right_limit)
            limit_value = (left_limit + right_limit) / 2.0
            {
              valid: true,
              expression: @expression,
              approach_value: @approach_value,
              direction: @direction,
              limit: format_result(limit_value),
              limit_numeric: limit_value,
              left_limit: format_result(left_limit),
              right_limit: format_result(right_limit),
              exists: true
            }
          else
            {
              valid: true,
              expression: @expression,
              approach_value: @approach_value,
              direction: @direction,
              limit: "Does not exist",
              left_limit: format_result(left_limit),
              right_limit: format_result(right_limit),
              exists: false
            }
          end
        else
          {
            valid: true,
            expression: @expression,
            approach_value: @approach_value,
            direction: @direction,
            limit: "Does not exist (diverges)",
            left_limit: left_limit ? format_result(left_limit) : "diverges",
            right_limit: right_limit ? format_result(right_limit) : "diverges",
            exists: false
          }
        end
      else
        one_sided = @direction == "left" ? left_limit : right_limit
        if one_sided
          {
            valid: true,
            expression: @expression,
            approach_value: @approach_value,
            direction: @direction,
            limit: format_result(one_sided),
            limit_numeric: one_sided,
            exists: true
          }
        else
          {
            valid: true,
            expression: @expression,
            approach_value: @approach_value,
            direction: @direction,
            limit: "Diverges",
            exists: false
          }
        end
      end
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

    def parse_approach_value(val)
      case val.downcase
      when "infinity", "inf", "+infinity", "+inf" then Float::INFINITY
      when "-infinity", "-inf" then -Float::INFINITY
      when "pi" then ::Math::PI
      when "e" then ::Math::E
      else val.to_f
      end
    end

    def compute_limit(ast, target, side)
      if target.infinite?
        return compute_limit_at_infinity(ast, target)
      end

      values = []
      epsilon = EPSILON_START
      while epsilon >= EPSILON_MIN
        x = side == :left ? target - epsilon : target + epsilon
        begin
          val = Evaluator.evaluate(ast, x)
          if val.finite?
            values << val
          else
            return nil if values.empty?
          end
        rescue StandardError
          return nil if values.empty?
        end
        epsilon *= EPSILON_FACTOR
      end

      return nil if values.empty?

      # Check convergence
      last_values = values.last(3)
      return nil if last_values.length < 2

      if last_values.all? { |v| close_enough?(v, last_values.last) }
        last_values.last
      else
        nil
      end
    end

    def compute_limit_at_infinity(ast, target)
      sign = target > 0 ? 1.0 : -1.0
      values = []
      [1e2, 1e4, 1e6, 1e8, 1e10].each do |n|
        x = sign * n
        begin
          val = Evaluator.evaluate(ast, x)
          values << val if val.finite?
        rescue StandardError
          next
        end
      end

      return nil if values.length < 3

      last_values = values.last(3)
      if last_values.all? { |v| close_enough?(v, last_values.last) }
        last_values.last
      else
        nil
      end
    end

    def close_enough?(a, b)
      return true if a == b
      diff = (a - b).abs
      magnitude = [a.abs, b.abs, 1.0].max
      diff / magnitude < 1e-6
    end

    def format_result(value)
      return "0" if value.abs < 1e-12
      if value == value.to_i.to_f && value.abs < 1e15
        value.to_i.to_s
      elsif value.abs >= 1e6 || (value.abs > 0 && value.abs < 1e-4)
        value.to_f.round(8).to_s
      else
        ("%.8g" % value)
      end
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
          node = [:binop, op, node, right]
        end
        node
      end

      def parse_term
        node = parse_unary
        while peek[:type] == :op && %w[* /].include?(peek[:value])
          op = consume[:value]
          right = parse_unary
          node = [:binop, op, node, right]
        end
        node
      end

      def parse_unary
        if peek[:type] == :op && peek[:value] == "-"
          consume
          return [:neg, parse_unary]
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
          return [:binop, "^", base, exponent]
        end
        base
      end

      def parse_primary
        tok = peek
        case tok[:type]
        when :number
          consume
          [:num, tok[:value].to_f]
        when :ident
          consume
          name = tok[:value]
          if peek[:type] == :lparen
            raise ParseError, "unknown function '#{name}'" unless FUNCTIONS.include?(name)
            consume
            arg = parse_expression
            raise ParseError, "missing closing parenthesis" unless peek[:type] == :rparen
            consume
            [:func, name, arg]
          else
            case name
            when "x" then [:var]
            when "pi" then [:num, ::Math::PI]
            when "e" then [:num, ::Math::E]
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

    module Evaluator
      module_function

      def evaluate(node, x)
        case node[0]
        when :num then node[1]
        when :var then x
        when :neg then -evaluate(node[1], x)
        when :binop
          a = evaluate(node[2], x)
          b = evaluate(node[3], x)
          case node[1]
          when "+" then a + b
          when "-" then a - b
          when "*" then a * b
          when "/"
            raise MathError, "Division by zero" if b.zero?
            a / b
          when "^" then a**b
          end
        when :func
          arg = evaluate(node[2], x)
          case node[1]
          when "sin" then ::Math.sin(arg)
          when "cos" then ::Math.cos(arg)
          when "tan" then ::Math.tan(arg)
          when "asin" then ::Math.asin(arg)
          when "acos" then ::Math.acos(arg)
          when "atan" then ::Math.atan(arg)
          when "sinh" then ::Math.sinh(arg)
          when "cosh" then ::Math.cosh(arg)
          when "tanh" then ::Math.tanh(arg)
          when "ln", "log" then ::Math.log(arg)
          when "log10" then ::Math.log10(arg)
          when "exp" then ::Math.exp(arg)
          when "sqrt" then ::Math.sqrt(arg)
          when "abs" then arg.abs
          end
        end
      end
    end
  end
end
