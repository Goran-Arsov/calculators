# frozen_string_literal: true

module Math
  class LimitCalculator
    # Assembles the result hash returned by LimitCalculator#call.
    # Separated from the calculator so the control flow of "what do the
    # computed limits mean" is independent of the numerical computation itself.
    class ResultBuilder
      CLOSE_ENOUGH_TOLERANCE = 1e-6

      def self.call(**kwargs)
        new(**kwargs).call
      end

      def initialize(expression:, approach_value:, direction:, left_limit:, right_limit:)
        @expression = expression
        @approach_value = approach_value
        @direction = direction
        @left_limit = left_limit
        @right_limit = right_limit
      end

      def call
        if @direction == "both"
          build_two_sided
        else
          build_one_sided
        end
      end

      private

      def build_two_sided
        if @left_limit && @right_limit
          if close_enough?(@left_limit, @right_limit)
            converged_two_sided
          else
            diverged_two_sided("Does not exist")
          end
        else
          diverged_two_sided("Does not exist (diverges)")
        end
      end

      def converged_two_sided
        limit_value = (@left_limit + @right_limit) / 2.0
        base_result.merge(
          limit: format_result(limit_value),
          limit_numeric: limit_value,
          left_limit: format_result(@left_limit),
          right_limit: format_result(@right_limit),
          exists: true
        )
      end

      def diverged_two_sided(message)
        base_result.merge(
          limit: message,
          left_limit: @left_limit ? format_result(@left_limit) : "diverges",
          right_limit: @right_limit ? format_result(@right_limit) : "diverges",
          exists: false
        )
      end

      def build_one_sided
        one_sided = @direction == "left" ? @left_limit : @right_limit
        if one_sided
          base_result.merge(
            limit: format_result(one_sided),
            limit_numeric: one_sided,
            exists: true
          )
        else
          base_result.merge(limit: "Diverges", exists: false)
        end
      end

      def base_result
        {
          valid: true,
          expression: @expression,
          approach_value: @approach_value,
          direction: @direction
        }
      end

      def close_enough?(a, b)
        return true if a == b

        diff = (a - b).abs
        magnitude = [ a.abs, b.abs, 1.0 ].max
        diff / magnitude < CLOSE_ENOUGH_TOLERANCE
      end

      def format_result(value)
        return "0" if value.abs < 1e-12
        if value == value.to_i.to_f && value.abs < 1e15
          value.to_i.to_s
        elsif value.abs >= 1e6 || (value.abs > 0 && value.abs < 1e-4)
          value.to_f.round(8).to_s
        else
          format("%.8g", value)
        end
      end
    end
  end
end
