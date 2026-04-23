# frozen_string_literal: true

module Math
  class BooleanAlgebraCalculator
    # Builds a complete truth table for an AST across the Cartesian product
    # of true/false assignments to the provided variables.
    # Output: array of { inputs: { "A" => true, ... }, output: true|false }.
    module TruthTable
      module_function

      def build(ast, vars)
        combinations = 2**vars.length
        Array.new(combinations) do |i|
          assignment = assignment_for(i, vars)
          { inputs: assignment, output: Evaluator.evaluate(ast, assignment) }
        end
      end

      def assignment_for(index, vars)
        vars.each_with_index.each_with_object({}) do |(name, j), acc|
          acc[name] = (index >> (vars.length - 1 - j)) & 1 == 1
        end
      end
    end
  end
end
