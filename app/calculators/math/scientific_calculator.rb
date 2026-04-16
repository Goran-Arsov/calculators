# frozen_string_literal: true

module Math
  # Evaluates arithmetic and scientific expressions safely via a hand-written
  # tokenizer + shunting-yard parser + RPN evaluator. Avoids `eval` entirely.
  #
  # Supported:
  #   - Numbers (integer, decimal, scientific notation like 1.5e3)
  #   - Operators: + - * / ^ %
  #   - Unary minus
  #   - Parentheses
  #   - Constants: pi, e
  #   - Functions: sin cos tan asin acos atan log ln sqrt exp abs
  #   - Postfix operators: ! (factorial) and ² (squared)
  #   - Trig mode: :rad or :deg
  class ScientificCalculator
    attr_reader :errors

    FUNCTIONS = %w[sin cos tan asin acos atan log ln sqrt exp abs].freeze
    CONSTANTS = { "pi" => ::Math::PI, "e" => ::Math::E }.freeze

    def initialize(expression:, mode: "rad")
      @expression = expression.to_s.strip
      @mode = mode.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      begin
        tokens = tokenize(@expression)
        rpn = to_rpn(tokens)
        result = evaluate_rpn(rpn)

        return { valid: false, errors: [ "Result is not a finite number" ] } unless result.finite?

        {
          valid: true,
          expression: @expression,
          mode: @mode,
          result: result,
          formatted: format_result(result)
        }
      rescue ArgumentError, ZeroDivisionError, RuntimeError => e
        { valid: false, errors: [ e.message ] }
      end
    end

    private

    def validate!
      @errors << "Expression is required" if @expression.empty?
      @errors << "Mode must be 'rad' or 'deg'" unless %w[rad deg].include?(@mode)
    end

    # --- Tokenizer ---
    def tokenize(expr)
      # Normalize: strip whitespace, lowercase function/constant names
      s = expr.gsub(/\s+/, "")
      tokens = []
      i = 0

      while i < s.length
        c = s[i]

        if c.match?(/\d|\./)
          # Number, possibly with scientific notation
          match = s[i..].match(/\A\d*\.?\d+(?:[eE][+-]?\d+)?/)
          raise ArgumentError, "Invalid number at position #{i}" unless match
          tokens << { type: :number, value: Float(match[0]) }
          i += match[0].length
        elsif c.match?(/[a-zA-Z]/)
          # Identifier: function name or constant
          match = s[i..].match(/\A[a-zA-Z]+/)
          name = match[0].downcase
          if FUNCTIONS.include?(name)
            tokens << { type: :function, value: name }
          elsif CONSTANTS.key?(name)
            tokens << { type: :number, value: CONSTANTS[name] }
          else
            raise ArgumentError, "Unknown identifier: #{name}"
          end
          i += match[0].length
        elsif %w[+ - * / ^ %].include?(c)
          # Detect unary minus/plus
          if c == "-" && unary_context?(tokens)
            tokens << { type: :operator, value: "neg", precedence: 4, right_assoc: true, unary: true }
          elsif c == "+" && unary_context?(tokens)
            # Skip unary plus
          else
            tokens << operator_token(c)
          end
          i += 1
        elsif c == "("
          tokens << { type: :lparen }
          i += 1
        elsif c == ")"
          tokens << { type: :rparen }
          i += 1
        elsif c == "!"
          tokens << { type: :operator, value: "fact", precedence: 5, right_assoc: false, postfix: true }
          i += 1
        elsif c == ","
          tokens << { type: :comma }
          i += 1
        else
          raise ArgumentError, "Unexpected character: #{c}"
        end
      end

      tokens
    end

    def unary_context?(tokens)
      return true if tokens.empty?
      last = tokens.last
      return true if last[:type] == :operator && !last[:postfix]
      return true if last[:type] == :lparen
      false
    end

    def operator_token(op)
      case op
      when "+" then { type: :operator, value: "+", precedence: 1, right_assoc: false }
      when "-" then { type: :operator, value: "-", precedence: 1, right_assoc: false }
      when "*" then { type: :operator, value: "*", precedence: 2, right_assoc: false }
      when "/" then { type: :operator, value: "/", precedence: 2, right_assoc: false }
      when "%" then { type: :operator, value: "%", precedence: 2, right_assoc: false }
      when "^" then { type: :operator, value: "^", precedence: 3, right_assoc: true }
      end
    end

    # --- Shunting-yard: infix to RPN ---
    def to_rpn(tokens)
      output = []
      stack = []

      tokens.each do |tok|
        case tok[:type]
        when :number
          output << tok
        when :function
          stack << tok
        when :operator
          if tok[:postfix]
            output << tok
          else
            while (top = stack.last) &&
                  top[:type] == :operator &&
                  !top[:right_assoc] &&
                  top[:precedence] >= tok[:precedence]
              output << stack.pop
            end
            while (top = stack.last) &&
                  top[:type] == :operator &&
                  top[:right_assoc] &&
                  top[:precedence] > tok[:precedence]
              output << stack.pop
            end
            stack << tok
          end
        when :lparen
          stack << tok
        when :rparen
          while stack.last && stack.last[:type] != :lparen
            output << stack.pop
          end
          raise ArgumentError, "Mismatched parentheses" if stack.empty?
          stack.pop # discard lparen
          if stack.last && stack.last[:type] == :function
            output << stack.pop
          end
        end
      end

      while (top = stack.pop)
        raise ArgumentError, "Mismatched parentheses" if top[:type] == :lparen
        output << top
      end

      output
    end

    # --- RPN evaluator ---
    def evaluate_rpn(rpn)
      stack = []

      rpn.each do |tok|
        case tok[:type]
        when :number
          stack << tok[:value]
        when :operator
          if tok[:value] == "neg"
            a = stack.pop or raise ArgumentError, "Missing operand for unary minus"
            stack << -a
          elsif tok[:value] == "fact"
            a = stack.pop or raise ArgumentError, "Missing operand for factorial"
            stack << factorial(a)
          else
            b = stack.pop or raise ArgumentError, "Missing right operand for #{tok[:value]}"
            a = stack.pop or raise ArgumentError, "Missing left operand for #{tok[:value]}"
            stack << apply_operator(tok[:value], a, b)
          end
        when :function
          a = stack.pop or raise ArgumentError, "Missing argument for #{tok[:value]}"
          stack << apply_function(tok[:value], a)
        end
      end

      raise ArgumentError, "Invalid expression" if stack.length != 1
      stack.first
    end

    def apply_operator(op, a, b)
      case op
      when "+" then a + b
      when "-" then a - b
      when "*" then a * b
      when "/"
        raise ZeroDivisionError, "Division by zero" if b.zero?
        a / b
      when "%"
        raise ZeroDivisionError, "Modulo by zero" if b.zero?
        a.remainder(b)
      when "^" then a**b
      end
    end

    def apply_function(name, arg)
      case name
      when "sin" then ::Math.sin(to_radians(arg))
      when "cos" then ::Math.cos(to_radians(arg))
      when "tan" then ::Math.tan(to_radians(arg))
      when "asin" then from_radians(::Math.asin(arg))
      when "acos" then from_radians(::Math.acos(arg))
      when "atan" then from_radians(::Math.atan(arg))
      when "log"  then ::Math.log10(arg)
      when "ln"   then ::Math.log(arg)
      when "sqrt" then ::Math.sqrt(arg)
      when "exp"  then ::Math.exp(arg)
      when "abs"  then arg.abs
      end
    end

    def to_radians(value)
      @mode == "deg" ? value * ::Math::PI / 180.0 : value
    end

    def from_radians(value)
      @mode == "deg" ? value * 180.0 / ::Math::PI : value
    end

    def factorial(n)
      raise ArgumentError, "Factorial only defined for non-negative integers" if n < 0 || n != n.to_i
      raise ArgumentError, "Factorial argument too large" if n > 170
      (1..n.to_i).inject(1) { |acc, i| acc * i }.to_f
    end

    def format_result(value)
      if value == value.to_i.to_f && value.abs < 1e15
        value.to_i.to_s
      elsif value.abs >= 1e15 || (value.abs < 1e-6 && value != 0)
        format("%.10g", value)
      else
        # Round to 10 significant digits, trim trailing zeros
        formatted = format("%.10g", value)
        formatted
      end
    end
  end
end
