module Math
  class BooleanAlgebraCalculator
    OPERATIONS = %w[simplify evaluate truth_table].freeze

    attr_reader :errors

    def initialize(expression:, operation: "simplify", variables: {})
      @expression = expression.to_s.strip
      @operation = operation.to_s.strip.downcase
      @variables = variables
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      tokens = tokenize(@expression)
      ast = parse(tokens)
      vars = extract_variables(ast).sort

      case @operation
      when "simplify"
        simplified = simplify(ast)
        simplified_str = ast_to_string(simplified)
        table = build_truth_table(ast, vars)
        simplified_table = build_truth_table(simplified, vars)

        {
          valid: true,
          expression: @expression,
          operation: @operation,
          simplified: simplified_str,
          original_ast: ast_to_string(ast),
          variables: vars,
          truth_table: table,
          equivalent: table == simplified_table
        }
      when "evaluate"
        val = evaluate(ast, @variables)
        {
          valid: true,
          expression: @expression,
          operation: @operation,
          result: val,
          display: val ? "TRUE (1)" : "FALSE (0)",
          variables: @variables
        }
      when "truth_table"
        table = build_truth_table(ast, vars)
        {
          valid: true,
          expression: @expression,
          operation: @operation,
          variables: vars,
          truth_table: table
        }
      end
    rescue ParseError => e
      @errors << "Invalid expression: #{e.message}"
      { valid: false, errors: @errors }
    end

    private

    def validate!
      @errors << "Expression cannot be blank" if @expression.empty?
      @errors << "Unsupported operation '#{@operation}'" unless OPERATIONS.include?(@operation)
    end

    # --- Tokenizer ---

    def tokenize(input)
      tokens = []
      i = 0
      src = input.upcase
      while i < src.length
        ch = src[i]
        if ch == " " || ch == "\t"
          i += 1
        elsif ch == "("
          tokens << { type: :lparen }
          i += 1
        elsif ch == ")"
          tokens << { type: :rparen }
          i += 1
        elsif ch == "!"
          tokens << { type: :not }
          i += 1
        elsif ch == "~"
          tokens << { type: :not }
          i += 1
        elsif ch == "'"
          tokens << { type: :not_postfix }
          i += 1
        elsif ch == "&" || (ch == "A" && src[i, 3] == "AND")
          if ch == "&"
            i += src[i, 2] == "&&" ? 2 : 1
          else
            i += 3
          end
          tokens << { type: :and }
        elsif ch == "|" || (ch == "O" && src[i, 2] == "OR" && (i + 2 >= src.length || !src[i + 2].match?(/[A-Z0-9_]/)))
          if ch == "|"
            i += src[i, 2] == "||" ? 2 : 1
          else
            i += 2
          end
          tokens << { type: :or }
        elsif ch == "^" || (ch == "X" && src[i, 3] == "XOR")
          if ch == "^"
            i += 1
          else
            i += 3
          end
          tokens << { type: :xor }
        elsif ch == "N" && src[i, 3] == "NOT"
          tokens << { type: :not }
          i += 3
        elsif ch == "0"
          tokens << { type: :literal, value: false }
          i += 1
        elsif ch == "1"
          tokens << { type: :literal, value: true }
          i += 1
        elsif ch.match?(/[A-Z_]/)
          start = i
          i += 1 while i < src.length && src[i].match?(/[A-Z0-9_]/)
          name = src[start...i]
          next if %w[AND OR NOT XOR].include?(name)
          tokens << { type: :var, value: name }
        else
          raise ParseError, "unexpected character '#{ch}'"
        end
      end
      tokens << { type: :eof }
      tokens
    end

    class ParseError < StandardError; end

    # --- Parser (recursive descent) ---
    # Precedence: NOT > AND > XOR > OR

    def parse(tokens)
      @tokens = tokens
      @pos = 0
      node = parse_or
      raise ParseError, "unexpected token after expression" unless peek[:type] == :eof
      node
    end

    def parse_or
      node = parse_xor
      while peek[:type] == :or
        consume
        right = parse_xor
        node = [ :or, node, right ]
      end
      node
    end

    def parse_xor
      node = parse_and
      while peek[:type] == :xor
        consume
        right = parse_and
        node = [ :xor, node, right ]
      end
      node
    end

    def parse_and
      node = parse_not
      while peek[:type] == :and
        consume
        right = parse_not
        node = [ :and, node, right ]
      end
      node
    end

    def parse_not
      if peek[:type] == :not
        consume
        operand = parse_not
        return [ :not, operand ]
      end
      parse_primary
    end

    def parse_primary
      tok = peek
      case tok[:type]
      when :literal
        consume
        node = [ :literal, tok[:value] ]
        # Handle postfix NOT (e.g., A')
        while peek[:type] == :not_postfix
          consume
          node = [ :not, node ]
        end
        node
      when :var
        consume
        node = [ :var, tok[:value] ]
        while peek[:type] == :not_postfix
          consume
          node = [ :not, node ]
        end
        node
      when :lparen
        consume
        node = parse_or
        raise ParseError, "missing closing parenthesis" unless peek[:type] == :rparen
        consume
        while peek[:type] == :not_postfix
          consume
          node = [ :not, node ]
        end
        node
      else
        raise ParseError, "unexpected token"
      end
    end

    def peek
      @tokens[@pos] || { type: :eof }
    end

    def consume
      tok = @tokens[@pos]
      @pos += 1
      tok
    end

    # --- Evaluator ---

    def evaluate(node, vars)
      case node[0]
      when :literal then node[1]
      when :var
        val = vars[node[1]] || vars[node[1].downcase] || vars[node[1].to_sym] || vars[node[1].downcase.to_sym]
        val ? true : false
      when :not then !evaluate(node[1], vars)
      when :and then evaluate(node[1], vars) & evaluate(node[2], vars)
      when :or then evaluate(node[1], vars) | evaluate(node[2], vars)
      when :xor then evaluate(node[1], vars) ^ evaluate(node[2], vars)
      end
    end

    # --- Simplifier ---

    def simplify(node)
      return node if node.nil?

      case node[0]
      when :literal, :var
        node
      when :not
        inner = simplify(node[1])
        # Double negation: NOT(NOT(x)) = x
        return inner[1] if inner[0] == :not
        # NOT(0) = 1, NOT(1) = 0
        return [ :literal, !inner[1] ] if inner[0] == :literal
        [ :not, inner ]
      when :and
        left = simplify(node[1])
        right = simplify(node[2])
        # Identity: A AND 1 = A
        return left if right == [ :literal, true ]
        return right if left == [ :literal, true ]
        # Annihilation: A AND 0 = 0
        return [ :literal, false ] if left == [ :literal, false ] || right == [ :literal, false ]
        # Idempotent: A AND A = A
        return left if left == right
        # Complement: A AND NOT(A) = 0
        return [ :literal, false ] if complement?(left, right)
        [ :and, left, right ]
      when :or
        left = simplify(node[1])
        right = simplify(node[2])
        # Identity: A OR 0 = A
        return left if right == [ :literal, false ]
        return right if left == [ :literal, false ]
        # Annihilation: A OR 1 = 1
        return [ :literal, true ] if left == [ :literal, true ] || right == [ :literal, true ]
        # Idempotent: A OR A = A
        return left if left == right
        # Complement: A OR NOT(A) = 1
        return [ :literal, true ] if complement?(left, right)
        [ :or, left, right ]
      when :xor
        left = simplify(node[1])
        right = simplify(node[2])
        # A XOR 0 = A
        return left if right == [ :literal, false ]
        return right if left == [ :literal, false ]
        # A XOR 1 = NOT(A)
        return simplify([ :not, left ]) if right == [ :literal, true ]
        return simplify([ :not, right ]) if left == [ :literal, true ]
        # A XOR A = 0
        return [ :literal, false ] if left == right
        [ :xor, left, right ]
      else
        node
      end
    end

    def complement?(a, b)
      (a[0] == :not && a[1] == b) || (b[0] == :not && b[1] == a)
    end

    # --- AST to string ---

    def ast_to_string(node)
      case node[0]
      when :literal then node[1] ? "1" : "0"
      when :var then node[1]
      when :not
        inner = ast_to_string(node[1])
        if node[1][0] == :var || node[1][0] == :literal
          "NOT #{inner}"
        else
          "NOT (#{inner})"
        end
      when :and
        left = wrap_lower_prec(node[1], :and)
        right = wrap_lower_prec(node[2], :and)
        "#{left} AND #{right}"
      when :or
        left = wrap_lower_prec(node[1], :or)
        right = wrap_lower_prec(node[2], :or)
        "#{left} OR #{right}"
      when :xor
        left = wrap_lower_prec(node[1], :xor)
        right = wrap_lower_prec(node[2], :xor)
        "#{left} XOR #{right}"
      end
    end

    def wrap_lower_prec(node, parent_op)
      str = ast_to_string(node)
      prec_map = { not: 4, and: 3, xor: 2, or: 1, literal: 5, var: 5 }
      child_prec = prec_map[node[0]] || 0
      parent_prec = prec_map[parent_op] || 0
      child_prec < parent_prec ? "(#{str})" : str
    end

    # --- Variable extraction ---

    def extract_variables(node)
      case node[0]
      when :literal then []
      when :var then [ node[1] ]
      when :not then extract_variables(node[1])
      when :and, :or, :xor
        (extract_variables(node[1]) + extract_variables(node[2])).uniq
      else []
      end
    end

    # --- Truth table ---

    def build_truth_table(ast, vars)
      rows = []
      combinations = 2**vars.length
      combinations.times do |i|
        assignment = {}
        vars.each_with_index do |v, j|
          assignment[v] = (i >> (vars.length - 1 - j)) & 1 == 1
        end
        result = evaluate(ast, assignment)
        rows << { inputs: assignment, output: result }
      end
      rows
    end
  end
end
