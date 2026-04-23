# frozen_string_literal: true

module Math
  class DerivativeCalculator
    # Applies differentiation rules to an AST and returns a new AST
    # representing the raw (un-simplified) derivative.
    #
    # AST shapes:
    #   [:num, value]
    #   [:var]
    #   [:neg, node]
    #   [:binop, op, left, right]   # op in +, -, *, /, ^
    #   [:func, name, arg]          # name in sin, cos, tan, exp, ln, log, sqrt
    class Differentiator
      def self.call(node)
        new.call(node)
      end

      def call(node)
        case node[0]
        when :num
          [ :num, 0 ]
        when :var
          [ :num, 1 ]
        when :neg
          [ :neg, call(node[1]) ]
        when :binop
          differentiate_binop(node)
        when :func
          differentiate_func(node)
        end
      end

      private

      def differentiate_binop(node)
        op, u, v = node[1], node[2], node[3]

        case op
        when "+"
          [ :binop, "+", call(u), call(v) ]
        when "-"
          [ :binop, "-", call(u), call(v) ]
        when "*"
          # Product rule: u'v + uv'
          [ :binop, "+",
            [ :binop, "*", call(u), v ],
            [ :binop, "*", u, call(v) ] ]
        when "/"
          # Quotient rule: (u'v - uv') / v^2
          [ :binop, "/",
            [ :binop, "-",
              [ :binop, "*", call(u), v ],
              [ :binop, "*", u, call(v) ] ],
            [ :binop, "^", v, [ :num, 2 ] ] ]
        when "^"
          differentiate_power(node, u, v)
        end
      end

      def differentiate_power(node, u, v)
        if constant?(v) && !constant?(u)
          # Power rule: n * u^(n-1) * u'
          n = v
          [ :binop, "*",
            [ :binop, "*", n, [ :binop, "^", u, [ :binop, "-", n, [ :num, 1 ] ] ] ],
            call(u) ]
        elsif constant?(u) && !constant?(v)
          # a^v = a^v * ln(a) * v'
          [ :binop, "*",
            [ :binop, "*", node, [ :func, "ln", u ] ],
            call(v) ]
        else
          # General: d/dx(u^v) = u^v * (v' * ln(u) + v * u'/u)
          [ :binop, "*", node,
            [ :binop, "+",
              [ :binop, "*", call(v), [ :func, "ln", u ] ],
              [ :binop, "*", v, [ :binop, "/", call(u), u ] ] ] ]
        end
      end

      def differentiate_func(node)
        name, u = node[1], node[2]
        du = call(u)
        inner = case name
        when "sin"
          [ :func, "cos", u ]
        when "cos"
          [ :neg, [ :func, "sin", u ] ]
        when "tan"
          # sec^2(u) = 1/cos^2(u)
          [ :binop, "/", [ :num, 1 ], [ :binop, "^", [ :func, "cos", u ], [ :num, 2 ] ] ]
        when "exp"
          [ :func, "exp", u ]
        when "ln", "log"
          [ :binop, "/", [ :num, 1 ], u ]
        when "sqrt"
          # 1/(2*sqrt(u))
          [ :binop, "/", [ :num, 1 ], [ :binop, "*", [ :num, 2 ], [ :func, "sqrt", u ] ] ]
        else
          [ :num, 0 ]
        end
        # Chain rule: f'(u) * u'
        [ :binop, "*", inner, du ]
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
    end
  end
end
