module Math
  class IntegralCalculator
    DEFAULT_INTERVALS = 1000
    MAX_INTERVALS = 100_000
    MIN_INTERVALS = 2

    FUNCTIONS = %w[sin cos tan asin acos atan sinh cosh tanh ln log log10 exp sqrt abs].freeze

    attr_reader :errors

    def initialize(expression:, lower:, upper:, intervals: DEFAULT_INTERVALS)
      @expression = expression.to_s.strip
      @lower = lower.to_f
      @upper = upper.to_f
      @intervals = intervals.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      ast = Parser.new(@expression).parse
      sign = 1.0
      a = @lower
      b = @upper
      if a > b
        a, b = b, a
        sign = -1.0
      end

      n = @intervals.even? ? @intervals : @intervals + 1
      h = (b - a) / n

      total = evaluate(ast, a) + evaluate(ast, b)
      (1...n).each do |i|
        x = a + i * h
        coeff = i.odd? ? 4.0 : 2.0
        total += coeff * evaluate(ast, x)
      end

      result = sign * (h / 3.0) * total

      unless result.finite?
        @errors << "Function is undefined or diverges over the interval"
        return { valid: false, errors: @errors }
      end

      {
        valid: true,
        result: result,
        expression: @expression,
        lower: @lower,
        upper: @upper,
        intervals: n,
        method: "Simpson's rule"
      }
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
      @errors << "Lower bound must be a finite number" unless @lower.finite?
      @errors << "Upper bound must be a finite number" unless @upper.finite?
      if @intervals < MIN_INTERVALS
        @errors << "Number of intervals must be at least #{MIN_INTERVALS}"
      elsif @intervals > MAX_INTERVALS
        @errors << "Number of intervals cannot exceed #{MAX_INTERVALS}"
      end
    end

    def evaluate(node, x)
      Evaluator.evaluate(node, x)
    end

    class ParseError < StandardError; end
    class MathError < StandardError; end

    class Parser
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
        if @pos < @input.length && (@input[@pos] == "e" || @input[@pos] == "E")
          if @pos + 1 < @input.length && @input[@pos + 1] =~ /[0-9+\-]/
            @pos += 1
            @pos += 1 if @input[@pos] == "+" || @input[@pos] == "-"
            while @pos < @input.length && @input[@pos] =~ /[0-9]/
              @pos += 1
            end
          end
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
        when :num
          node[1]
        when :var
          x
        when :neg
          -evaluate(node[1], x)
        when :binop
          a = evaluate(node[2], x)
          b = evaluate(node[3], x)
          case node[1]
          when "+" then a + b
          when "-" then a - b
          when "*" then a * b
          when "/"
            raise MathError, "Division by zero in expression" if b.zero?
            a / b
          when "^" then a**b
          end
        when :func
          arg = evaluate(node[2], x)
          apply_function(node[1], arg)
        end
      end

      def apply_function(name, arg)
        case name
        when "sin" then ::Math.sin(arg)
        when "cos" then ::Math.cos(arg)
        when "tan" then ::Math.tan(arg)
        when "asin" then ::Math.asin(arg)
        when "acos" then ::Math.acos(arg)
        when "atan" then ::Math.atan(arg)
        when "sinh" then ::Math.sinh(arg)
        when "cosh" then ::Math.cosh(arg)
        when "tanh" then ::Math.tanh(arg)
        when "ln" then ::Math.log(arg)
        when "log" then ::Math.log(arg)
        when "log10" then ::Math.log10(arg)
        when "exp" then ::Math.exp(arg)
        when "sqrt" then ::Math.sqrt(arg)
        when "abs" then arg.abs
        end
      end
    end
  end
end
