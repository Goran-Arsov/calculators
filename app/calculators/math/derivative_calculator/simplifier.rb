# frozen_string_literal: true

module Math
  class DerivativeCalculator
    # Simplifies a derivative AST by folding constants and eliminating
    # identity operations (x + 0, x * 1, x * 0, etc.).
    #
    # Pure function of the input AST — same input always yields the same output.
    class Simplifier
      def self.call(node)
        new.call(node)
      end

      def call(node)
        return node if node.nil?

        case node[0]
        when :num, :var
          node
        when :neg
          simplify_neg(node)
        when :binop
          simplify_binop(node)
        when :func
          [ :func, node[1], call(node[2]) ]
        else
          node
        end
      end

      private

      def simplify_neg(node)
        inner = call(node[1])
        return [ :num, 0 ] if inner == [ :num, 0 ]
        return [ :num, -inner[1] ] if inner[0] == :num

        [ :neg, inner ]
      end

      def simplify_binop(node)
        op = node[1]
        left = call(node[2])
        right = call(node[3])

        # Constant folding
        if left[0] == :num && right[0] == :num
          val = eval_const(op, left[1], right[1])
          return [ :num, val ] if val
        end

        folded = fold_identity(op, left, right)
        return folded if folded

        [ :binop, op, left, right ]
      end

      def fold_identity(op, left, right)
        case op
        when "+"
          return right if left == [ :num, 0 ]
          return left if right == [ :num, 0 ]
        when "-"
          return [ :neg, right ] if left == [ :num, 0 ]
          return left if right == [ :num, 0 ]
          return [ :num, 0 ] if left == right
        when "*"
          return [ :num, 0 ] if left == [ :num, 0 ] || right == [ :num, 0 ]
          return right if left == [ :num, 1 ]
          return left if right == [ :num, 1 ]
          return [ :neg, right ] if left == [ :num, -1 ]
          return [ :neg, left ] if right == [ :num, -1 ]
        when "/"
          return [ :num, 0 ] if left == [ :num, 0 ]
          return left if right == [ :num, 1 ]
        when "^"
          return [ :num, 1 ] if right == [ :num, 0 ]
          return left if right == [ :num, 1 ]
          return [ :num, 0 ] if left == [ :num, 0 ]
        end
        nil
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
    end
  end
end
