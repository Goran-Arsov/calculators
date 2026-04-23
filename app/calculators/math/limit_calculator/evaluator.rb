# frozen_string_literal: true

module Math
  class LimitCalculator
    # Evaluates a parsed expression AST at a specific x value.
    # Raises MathError for division by zero; callers catch StandardError
    # (e.g. Math::DomainError from sqrt of negative) to detect divergence.
    module Evaluator
      module_function

      def evaluate(node, x)
        case node[0]
        when :num then node[1]
        when :var then x
        when :neg then -evaluate(node[1], x)
        when :binop then evaluate_binop(node, x)
        when :func then evaluate_func(node, x)
        end
      end

      def evaluate_binop(node, x)
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
      end

      def evaluate_func(node, x)
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
