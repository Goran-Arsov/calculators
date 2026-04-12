module Math
  class TaylorSeriesCalculator
    SUPPORTED_FUNCTIONS = %w[exp sin cos ln_1_plus_x one_over_1_minus_x sinh cosh atan].freeze
    MAX_TERMS = 20
    MIN_TERMS = 1

    attr_reader :errors

    def initialize(function:, center: 0, num_terms: 5)
      @function = function.to_s.strip.downcase
      @center = center.to_f
      @num_terms = num_terms.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      terms = compute_terms
      polynomial = format_polynomial(terms)
      evaluated_terms = terms.map { |t| { coefficient: t[:coefficient], power: t[:power], term: t[:term_str] } }

      {
        valid: true,
        function: @function,
        function_display: function_display_name,
        center: @center,
        num_terms: @num_terms,
        polynomial: polynomial,
        terms: evaluated_terms,
        is_maclaurin: @center.zero?
      }
    end

    private

    def validate!
      @errors << "Function cannot be blank" if @function.empty?
      @errors << "Unsupported function '#{@function}'. Supported: #{SUPPORTED_FUNCTIONS.join(', ')}" unless SUPPORTED_FUNCTIONS.include?(@function)
      @errors << "Number of terms must be between #{MIN_TERMS} and #{MAX_TERMS}" if @num_terms < MIN_TERMS || @num_terms > MAX_TERMS
      if @function == "ln_1_plus_x" && @center != 0
        @errors << "ln(1+x) Taylor expansion is only supported around center = 0"
      end
      if @function == "one_over_1_minus_x" && @center != 0
        @errors << "1/(1-x) Taylor expansion is only supported around center = 0"
      end
    end

    def compute_terms
      case @function
      when "exp" then exp_terms
      when "sin" then sin_terms
      when "cos" then cos_terms
      when "ln_1_plus_x" then ln_1_plus_x_terms
      when "one_over_1_minus_x" then one_over_1_minus_x_terms
      when "sinh" then sinh_terms
      when "cosh" then cosh_terms
      when "atan" then atan_terms
      end
    end

    def exp_terms
      terms = []
      @num_terms.times do |n|
        coeff = 1.0 / factorial(n)
        terms << { coefficient: coeff, power: n, term_str: format_term(coeff, n) }
      end
      terms
    end

    def sin_terms
      terms = []
      @num_terms.times do |k|
        n = 2 * k + 1
        sign = ((-1)**k)
        coeff = sign.to_f / factorial(n)
        terms << { coefficient: coeff, power: n, term_str: format_term(coeff, n) }
      end
      terms
    end

    def cos_terms
      terms = []
      @num_terms.times do |k|
        n = 2 * k
        sign = ((-1)**k)
        coeff = sign.to_f / factorial(n)
        terms << { coefficient: coeff, power: n, term_str: format_term(coeff, n) }
      end
      terms
    end

    def ln_1_plus_x_terms
      terms = []
      @num_terms.times do |k|
        n = k + 1
        sign = ((-1)**(n + 1))
        coeff = sign.to_f / n
        terms << { coefficient: coeff, power: n, term_str: format_term(coeff, n) }
      end
      terms
    end

    def one_over_1_minus_x_terms
      terms = []
      @num_terms.times do |n|
        terms << { coefficient: 1.0, power: n, term_str: format_term(1.0, n) }
      end
      terms
    end

    def sinh_terms
      terms = []
      @num_terms.times do |k|
        n = 2 * k + 1
        coeff = 1.0 / factorial(n)
        terms << { coefficient: coeff, power: n, term_str: format_term(coeff, n) }
      end
      terms
    end

    def cosh_terms
      terms = []
      @num_terms.times do |k|
        n = 2 * k
        coeff = 1.0 / factorial(n)
        terms << { coefficient: coeff, power: n, term_str: format_term(coeff, n) }
      end
      terms
    end

    def atan_terms
      terms = []
      @num_terms.times do |k|
        n = 2 * k + 1
        sign = ((-1)**k)
        coeff = sign.to_f / n
        terms << { coefficient: coeff, power: n, term_str: format_term(coeff, n) }
      end
      terms
    end

    def factorial(n)
      return 1 if n <= 1
      (2..n).inject(:*)
    end

    def format_term(coeff, power)
      return format_coefficient(coeff) if power.zero?

      var = @center.zero? ? "x" : "(x - #{format_number(@center)})"
      power_str = power == 1 ? var : "#{var}^#{power}"

      if coeff == 1.0
        power_str
      elsif coeff == -1.0
        "-#{power_str}"
      else
        "#{format_coefficient(coeff)}#{power_str}"
      end
    end

    def format_coefficient(coeff)
      if coeff == coeff.to_i.to_f
        coeff.to_i.to_s
      else
        # Try to express as fraction for readability
        frac = to_fraction(coeff)
        frac || ("%.8g" % coeff)
      end
    end

    def format_number(n)
      n == n.to_i.to_f ? n.to_i.to_s : n.to_s
    end

    def to_fraction(val)
      return nil if val.zero?
      sign = val < 0 ? "-" : ""
      val = val.abs
      # Try denominators up to 5040 (7!)
      (1..5040).each do |d|
        n = (val * d).round
        if (n.to_f / d - val).abs < 1e-12
          g = n.gcd(d)
          n /= g
          d_reduced = d / g
          return d_reduced == 1 ? "#{sign}#{n}" : "#{sign}#{n}/#{d_reduced}"
        end
      end
      nil
    end

    def format_polynomial(terms)
      return "0" if terms.empty?

      parts = []
      terms.each_with_index do |t, i|
        next if t[:coefficient].zero?
        if i.zero?
          parts << t[:term_str]
        else
          if t[:coefficient] > 0
            parts << "+ #{t[:term_str]}"
          else
            # term_str already has the minus
            parts << "- #{t[:term_str].sub(/\A-/, '')}"
          end
        end
      end
      parts.join(" ") + " + ..."
    end

    def function_display_name
      case @function
      when "exp" then "e^x"
      when "sin" then "sin(x)"
      when "cos" then "cos(x)"
      when "ln_1_plus_x" then "ln(1+x)"
      when "one_over_1_minus_x" then "1/(1-x)"
      when "sinh" then "sinh(x)"
      when "cosh" then "cosh(x)"
      when "atan" then "atan(x)"
      end
    end
  end
end
