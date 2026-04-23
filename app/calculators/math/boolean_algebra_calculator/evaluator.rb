# frozen_string_literal: true

module Math
  class BooleanAlgebraCalculator
    # Evaluates a boolean AST against a variable assignment hash.
    # Lookup is forgiving: accepts the variable key as uppercase string,
    # lowercase string, or a symbol of either casing.
    module Evaluator
      module_function

      def evaluate(node, vars)
        case node[0]
        when :literal then node[1]
        when :var     then lookup(vars, node[1])
        when :not     then !evaluate(node[1], vars)
        when :and     then evaluate(node[1], vars) & evaluate(node[2], vars)
        when :or      then evaluate(node[1], vars) | evaluate(node[2], vars)
        when :xor     then evaluate(node[1], vars) ^ evaluate(node[2], vars)
        end
      end

      def lookup(vars, name)
        val = vars[name] || vars[name.downcase] || vars[name.to_sym] || vars[name.downcase.to_sym]
        val ? true : false
      end
    end
  end
end
