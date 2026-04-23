# frozen_string_literal: true

module Math
  class DerivativeCalculator
    # Converts a derivative AST back to a human-readable infix string,
    # parenthesizing only where operator precedence requires it.
    class Printer
      def self.call(node, variable:)
        new(variable).call(node)
      end

      def initialize(variable)
        @variable = variable
      end

      def call(node)
        case node[0]
        when :num
          format_num(node[1])
        when :var
          @variable
        when :neg
          inner = call(node[1])
          "-#{wrap_if_compound(node[1], inner)}"
        when :binop
          format_binop(node)
        when :func
          "#{node[1]}(#{call(node[2])})"
        end
      end

      private

      def format_num(n)
        n == n.to_i ? n.to_i.to_s : n.to_s
      end

      def format_binop(node)
        op = node[1]
        left = call(node[2])
        right = call(node[3])
        left = wrap_if_lower_precedence(node[2], op, :left, left)
        right = wrap_if_lower_precedence(node[3], op, :right, right)
        "#{left} #{op} #{right}"
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
    end
  end
end
