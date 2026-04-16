# frozen_string_literal: true

module Math
  class ComplexNumberCalculator
    OPERATIONS = %w[add subtract multiply divide magnitude conjugate to_polar to_rectangular].freeze

    attr_reader :errors

    def initialize(operation:, real1: 0, imag1: 0, real2: 0, imag2: 0, r: 0, theta: 0)
      @operation = operation.to_s.strip.downcase
      @real1 = real1.to_f
      @imag1 = imag1.to_f
      @real2 = real2.to_f
      @imag2 = imag2.to_f
      @r = r.to_f
      @theta = theta.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = compute
      result.merge(
        valid: true,
        operation: @operation
      )
    end

    private

    def validate!
      @errors << "Operation cannot be blank" if @operation.empty?
      @errors << "Unsupported operation '#{@operation}'" unless OPERATIONS.include?(@operation)
      if @operation == "divide" && @real2.zero? && @imag2.zero?
        @errors << "Cannot divide by zero"
      end
      if @operation == "to_rectangular" && @r < 0
        @errors << "Magnitude r must be non-negative"
      end
    end

    def compute
      case @operation
      when "add" then add
      when "subtract" then subtract
      when "multiply" then multiply
      when "divide" then divide
      when "magnitude" then magnitude
      when "conjugate" then conjugate
      when "to_polar" then to_polar
      when "to_rectangular" then to_rectangular
      end
    end

    def add
      real = @real1 + @real2
      imag = @imag1 + @imag2
      {
        real: real,
        imaginary: imag,
        display: format_complex(real, imag),
        z1: format_complex(@real1, @imag1),
        z2: format_complex(@real2, @imag2)
      }
    end

    def subtract
      real = @real1 - @real2
      imag = @imag1 - @imag2
      {
        real: real,
        imaginary: imag,
        display: format_complex(real, imag),
        z1: format_complex(@real1, @imag1),
        z2: format_complex(@real2, @imag2)
      }
    end

    def multiply
      # (a+bi)(c+di) = (ac-bd) + (ad+bc)i
      real = @real1 * @real2 - @imag1 * @imag2
      imag = @real1 * @imag2 + @imag1 * @real2
      {
        real: real,
        imaginary: imag,
        display: format_complex(real, imag),
        z1: format_complex(@real1, @imag1),
        z2: format_complex(@real2, @imag2)
      }
    end

    def divide
      # (a+bi)/(c+di) = ((ac+bd) + (bc-ad)i) / (c^2+d^2)
      denom = @real2**2 + @imag2**2
      real = (@real1 * @real2 + @imag1 * @imag2) / denom
      imag = (@imag1 * @real2 - @real1 * @imag2) / denom
      {
        real: real,
        imaginary: imag,
        display: format_complex(real, imag),
        z1: format_complex(@real1, @imag1),
        z2: format_complex(@real2, @imag2)
      }
    end

    def magnitude
      mag = ::Math.sqrt(@real1**2 + @imag1**2)
      {
        magnitude: mag,
        display: format_number(mag),
        z1: format_complex(@real1, @imag1)
      }
    end

    def conjugate
      {
        real: @real1,
        imaginary: -@imag1,
        display: format_complex(@real1, -@imag1),
        z1: format_complex(@real1, @imag1)
      }
    end

    def to_polar
      r = ::Math.sqrt(@real1**2 + @imag1**2)
      theta_rad = ::Math.atan2(@imag1, @real1)
      theta_deg = theta_rad * 180.0 / ::Math::PI
      {
        r: r,
        theta_radians: theta_rad,
        theta_degrees: theta_deg,
        display: "#{format_number(r)} \u2220 #{format_number(theta_deg)}\u00B0",
        z1: format_complex(@real1, @imag1)
      }
    end

    def to_rectangular
      real = @r * ::Math.cos(@theta * ::Math::PI / 180.0)
      imag = @r * ::Math.sin(@theta * ::Math::PI / 180.0)
      {
        real: real,
        imaginary: imag,
        display: format_complex(real, imag),
        polar_input: "#{format_number(@r)} \u2220 #{format_number(@theta)}\u00B0"
      }
    end

    def format_complex(real, imag)
      real = clean_number(real)
      imag = clean_number(imag)

      if imag.zero?
        format_number(real)
      elsif real.zero?
        imag == 1 ? "i" : imag == -1 ? "-i" : "#{format_number(imag)}i"
      else
        sign = imag >= 0 ? "+" : "-"
        imag_abs = imag.abs
        imag_str = imag_abs == 1 ? "i" : "#{format_number(imag_abs)}i"
        "#{format_number(real)} #{sign} #{imag_str}"
      end
    end

    def format_number(n)
      n = clean_number(n)
      if n == n.to_i.to_f && n.abs < 1e12
        n.to_i.to_s
      else
        ("%.6g" % n)
      end
    end

    def clean_number(n)
      n.abs < 1e-12 ? 0.0 : n
    end
  end
end
