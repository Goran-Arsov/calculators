# frozen_string_literal: true

module Math
  class BooleanAlgebraCalculator
    # Applies classical boolean-algebra identity rules to reduce an AST.
    # Rules applied: double-negation, identity, annihilation, idempotence,
    # and complement elimination.
    class Simplifier
      def self.call(node)
        new.call(node)
      end

      def call(node)
        return node if node.nil?

        case node[0]
        when :literal, :var then node
        when :not           then simplify_not(node)
        when :and           then simplify_and(node)
        when :or            then simplify_or(node)
        when :xor           then simplify_xor(node)
        else node
        end
      end

      private

      def simplify_not(node)
        inner = call(node[1])
        return inner[1] if inner[0] == :not                   # NOT(NOT(x)) = x
        return [ :literal, !inner[1] ] if inner[0] == :literal # NOT(0) = 1, NOT(1) = 0

        [ :not, inner ]
      end

      def simplify_and(node)
        left = call(node[1])
        right = call(node[2])
        return left if right == [ :literal, true ]
        return right if left == [ :literal, true ]
        return [ :literal, false ] if left == [ :literal, false ] || right == [ :literal, false ]
        return left if left == right
        return [ :literal, false ] if complement?(left, right)

        [ :and, left, right ]
      end

      def simplify_or(node)
        left = call(node[1])
        right = call(node[2])
        return left if right == [ :literal, false ]
        return right if left == [ :literal, false ]
        return [ :literal, true ] if left == [ :literal, true ] || right == [ :literal, true ]
        return left if left == right
        return [ :literal, true ] if complement?(left, right)

        [ :or, left, right ]
      end

      def simplify_xor(node)
        left = call(node[1])
        right = call(node[2])
        return left if right == [ :literal, false ]
        return right if left == [ :literal, false ]
        return call([ :not, left ]) if right == [ :literal, true ]
        return call([ :not, right ]) if left == [ :literal, true ]
        return [ :literal, false ] if left == right

        [ :xor, left, right ]
      end

      def complement?(a, b)
        (a[0] == :not && a[1] == b) || (b[0] == :not && b[1] == a)
      end
    end
  end
end
