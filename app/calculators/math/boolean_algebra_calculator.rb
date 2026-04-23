# frozen_string_literal: true

module Math
  # Simplifies, evaluates, or builds a truth table for a boolean-algebra expression.
  # Pipeline: tokenize -> parse -> (simplify | evaluate | truth_table) -> print.
  #
  # Each stage lives in a sibling file under boolean_algebra_calculator/.
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
      when "simplify"    then result_for_simplify(ast, vars)
      when "evaluate"    then result_for_evaluate(ast)
      when "truth_table" then result_for_truth_table(ast, vars)
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

    def result_for_simplify(ast, vars)
      simplified = Simplifier.call(ast)
      table = TruthTable.build(ast, vars)
      simplified_table = TruthTable.build(simplified, vars)

      {
        valid: true,
        expression: @expression,
        operation: @operation,
        simplified: Printer.call(simplified),
        original_ast: Printer.call(ast),
        variables: vars,
        truth_table: table,
        equivalent: table == simplified_table
      }
    end

    def result_for_evaluate(ast)
      val = Evaluator.evaluate(ast, @variables)
      {
        valid: true,
        expression: @expression,
        operation: @operation,
        result: val,
        display: val ? "TRUE (1)" : "FALSE (0)",
        variables: @variables
      }
    end

    def result_for_truth_table(ast, vars)
      {
        valid: true,
        expression: @expression,
        operation: @operation,
        variables: vars,
        truth_table: TruthTable.build(ast, vars)
      }
    end

    # --- Tokenizer ---

    IDENT_CHAR = /[A-Z0-9_]/
    KEYWORDS = %w[AND OR NOT XOR].freeze

    def tokenize(input)
      @src = input.upcase
      @pos_t = 0
      tokens = []
      while @pos_t < @src.length
        token = next_token
        tokens << token if token
      end
      tokens << { type: :eof }
      tokens
    end

    def next_token
      ch = @src[@pos_t]
      case ch
      when " ", "\t"        then @pos_t += 1; nil
      when "("              then advance_token({ type: :lparen }, 1)
      when ")"              then advance_token({ type: :rparen }, 1)
      when "!", "~"         then advance_token({ type: :not }, 1)
      when "'"              then advance_token({ type: :not_postfix }, 1)
      when "&"              then advance_token({ type: :and }, @src[@pos_t, 2] == "&&" ? 2 : 1)
      when "|"              then advance_token({ type: :or }, @src[@pos_t, 2] == "||" ? 2 : 1)
      when "^"              then advance_token({ type: :xor }, 1)
      when "0"              then advance_token({ type: :literal, value: false }, 1)
      when "1"              then advance_token({ type: :literal, value: true }, 1)
      else
        tokenize_word_or_raise(ch)
      end
    end

    def advance_token(token, step)
      @pos_t += step
      token
    end

    def tokenize_word_or_raise(ch)
      return advance_token({ type: :and }, 3) if substring_at?("AND")
      return advance_token({ type: :not }, 3) if substring_at?("NOT")
      return advance_token({ type: :xor }, 3) if substring_at?("XOR")
      # "OR" is the one keyword that requires a non-identifier follower,
      # so inputs like "ORANGE" are parsed as a single variable.
      return advance_token({ type: :or }, 2)  if substring_at?("OR") && !ident_char_after?("OR")
      return tokenize_identifier if ch.match?(/[A-Z_]/)

      raise ParseError, "unexpected character '#{ch}'"
    end

    def substring_at?(word)
      @src[@pos_t, word.length] == word
    end

    def ident_char_after?(word)
      after = @src[@pos_t + word.length]
      !after.nil? && after.match?(IDENT_CHAR)
    end

    def tokenize_identifier
      start = @pos_t
      @pos_t += 1 while @pos_t < @src.length && @src[@pos_t].match?(IDENT_CHAR)
      name = @src[start...@pos_t]
      return nil if KEYWORDS.include?(name)

      { type: :var, value: name }
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
  end
end
