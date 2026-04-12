module Math
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
      derivative_ast = differentiate(ast)
      simplified = simplify(derivative_ast)
      result_str = ast_to_string(simplified)

      {
        valid: true,
        expression: @expression,
        variable: @variable,
        derivative: result_str,
        steps: build_steps(ast, derivative_ast, simplified)
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

    def differentiate(node)
      case node[0]
      when :num
        [:num, 0]
      when :var
        [:num, 1]
      when :neg
        [:neg, differentiate(node[1])]
      when :binop
        op = node[1]
        u = node[2]
        v = node[3]
        case op
        when "+"
          [:binop, "+", differentiate(u), differentiate(v)]
        when "-"
          [:binop, "-", differentiate(u), differentiate(v)]
        when "*"
          # Product rule: u'v + uv'
          [:binop, "+",
            [:binop, "*", differentiate(u), v],
            [:binop, "*", u, differentiate(v)]]
        when "/"
          # Quotient rule: (u'v - uv') / v^2
          [:binop, "/",
            [:binop, "-",
              [:binop, "*", differentiate(u), v],
              [:binop, "*", u, differentiate(v)]],
            [:binop, "^", v, [:num, 2]]]
        when "^"
          if constant?(v) && !constant?(u)
            # Power rule: n * u^(n-1) * u'
            n = v
            [:binop, "*",
              [:binop, "*", n, [:binop, "^", u, [:binop, "-", n, [:num, 1]]]],
              differentiate(u)]
          elsif constant?(u) && !constant?(v)
            # a^v = a^v * ln(a) * v'
            [:binop, "*",
              [:binop, "*", node, [:func, "ln", u]],
              differentiate(v)]
          else
            # General: d/dx(u^v) = u^v * (v' * ln(u) + v * u'/u)
            [:binop, "*", node,
              [:binop, "+",
                [:binop, "*", differentiate(v), [:func, "ln", u]],
                [:binop, "*", v, [:binop, "/", differentiate(u), u]]]]
          end
        end
      when :func
        name = node[1]
        u = node[2]
        du = differentiate(u)
        inner = case name
                when "sin"
                  [:func, "cos", u]
                when "cos"
                  [:neg, [:func, "sin", u]]
                when "tan"
                  # sec^2(u) = 1/cos^2(u)
                  [:binop, "/", [:num, 1], [:binop, "^", [:func, "cos", u], [:num, 2]]]
                when "exp"
                  [:func, "exp", u]
                when "ln", "log"
                  [:binop, "/", [:num, 1], u]
                when "sqrt"
                  # 1/(2*sqrt(u))
                  [:binop, "/", [:num, 1], [:binop, "*", [:num, 2], [:func, "sqrt", u]]]
                else
                  [:num, 0]
                end
        # Chain rule: f'(u) * u'
        [:binop, "*", inner, du]
      end
    end

    def constant?(node)
      case node[0]
      when :num then true
      when :var then false
      when :neg then constant?(node[1])
      when :binop then constant?(node[2]) && constant?(node[3])
      when :func then constant?(node[2])
      else false
      end
    end

    def simplify(node)
      return node if node.nil?

      case node[0]
      when :num, :var
        node
      when :neg
        inner = simplify(node[1])
        return [:num, 0] if inner == [:num, 0]
        return [:num, -inner[1]] if inner[0] == :num
        [:neg, inner]
      when :binop
        op = node[1]
        left = simplify(node[2])
        right = simplify(node[3])

        # Constant folding
        if left[0] == :num && right[0] == :num
          val = eval_const(op, left[1], right[1])
          return [:num, val] if val
        end

        case op
        when "+"
          return right if left == [:num, 0]
          return left if right == [:num, 0]
        when "-"
          return [:neg, right] if left == [:num, 0]
          return left if right == [:num, 0]
          return [:num, 0] if left == right
        when "*"
          return [:num, 0] if left == [:num, 0] || right == [:num, 0]
          return right if left == [:num, 1]
          return left if right == [:num, 1]
          return [:neg, right] if left == [:num, -1]
          return [:neg, left] if right == [:num, -1]
        when "/"
          return [:num, 0] if left == [:num, 0]
          return left if right == [:num, 1]
        when "^"
          return [:num, 1] if right == [:num, 0]
          return left if right == [:num, 1]
          return [:num, 0] if left == [:num, 0]
        end

        [:binop, op, left, right]
      when :func
        inner = simplify(node[2])
        [:func, node[1], inner]
      else
        node
      end
    end

    def eval_const(op, a, b)
      case op
      when "+" then a + b
      when "-" then a - b
      when "*" then a * b
      when "/" then b.zero? ? nil : a.to_f / b
      when "^" then a**b
      end
    rescue StandardError
      nil
    end

    def ast_to_string(node)
      case node[0]
      when :num
        n = node[1]
        n == n.to_i ? n.to_i.to_s : n.to_s
      when :var
        @variable
      when :neg
        inner = ast_to_string(node[1])
        "-#{wrap_if_compound(node[1], inner)}"
      when :binop
        op = node[1]
        left = ast_to_string(node[2])
        right = ast_to_string(node[3])
        left = wrap_if_lower_precedence(node[2], op, :left, left)
        right = wrap_if_lower_precedence(node[3], op, :right, right)
        "#{left} #{op} #{right}"
      when :func
        "#{node[1]}(#{ast_to_string(node[2])})"
      end
    end

    def wrap_if_compound(node, str)
      if node[0] == :binop && %w[+ -].include?(node[1])
        "(#{str})"
      else
        str
      end
    end

    def wrap_if_lower_precedence(node, parent_op, side, str)
      return str unless node[0] == :binop

      child_prec = precedence(node[1])
      parent_prec = precedence(parent_op)

      if child_prec < parent_prec
        "(#{str})"
      elsif child_prec == parent_prec && side == :right && %w[- /].include?(parent_op)
        "(#{str})"
      else
        str
      end
    end

    def precedence(op)
      case op
      when "+", "-" then 1
      when "*", "/" then 2
      when "^" then 3
      else 0
      end
    end

    def build_steps(original, raw_derivative, simplified)
      [
        "Original: #{ast_to_string(original)}",
        "Raw derivative: #{ast_to_string(raw_derivative)}",
        "Simplified: #{ast_to_string(simplified)}"
      ]
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
            when @variable then [:var]
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
