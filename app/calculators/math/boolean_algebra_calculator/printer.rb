# frozen_string_literal: true

module Math
  class BooleanAlgebraCalculator
    # Converts a boolean AST back to a human-readable string using
    # keywords (AND / OR / NOT / XOR). Precedence: NOT > AND > XOR > OR.
    class Printer
      PRECEDENCE = { not: 4, and: 3, xor: 2, or: 1, literal: 5, var: 5 }.freeze

      def self.call(node)
        new.call(node)
      end

      def call(node)
        case node[0]
        when :literal then node[1] ? "1" : "0"
        when :var     then node[1]
        when :not     then format_not(node)
        when :and     then format_binop(node, "AND")
        when :or      then format_binop(node, "OR")
        when :xor     then format_binop(node, "XOR")
        end
      end

      private

      def format_not(node)
        inner = call(node[1])
        if node[1][0] == :var || node[1][0] == :literal
          "NOT #{inner}"
        else
          "NOT (#{inner})"
        end
      end

      def format_binop(node, label)
        op_sym = label.downcase.to_sym
        left = wrap_lower_prec(node[1], op_sym)
        right = wrap_lower_prec(node[2], op_sym)
        "#{left} #{label} #{right}"
      end

      def wrap_lower_prec(node, parent_op)
        str = call(node)
        child_prec = PRECEDENCE[node[0]] || 0
        parent_prec = PRECEDENCE[parent_op] || 0
        child_prec < parent_prec ? "(#{str})" : str
      end
    end
  end
end
