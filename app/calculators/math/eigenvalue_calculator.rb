module Math
  class EigenvalueCalculator
    attr_reader :errors

    def initialize(matrix:)
      @matrix = parse_matrix(matrix)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      size = @matrix.length
      result = size == 2 ? solve_2x2 : solve_3x3

      result.merge(
        valid: true,
        matrix: @matrix,
        size: "#{size}x#{size}"
      )
    end

    private

    def parse_matrix(input)
      case input
      when Array
        input.map { |row| row.is_a?(Array) ? row.map(&:to_f) : [ row.to_f ] }
      when String
        input.strip.split(";").map { |row| row.strip.split(/[\s,]+/).map(&:to_f) }
      else
        []
      end
    end

    def validate!
      @errors << "Matrix cannot be empty" if @matrix.empty?
      return if @matrix.empty?

      n = @matrix.length
      @errors << "Matrix must be 2x2 or 3x3" unless [ 2, 3 ].include?(n)
      @matrix.each_with_index do |row, i|
        @errors << "Row #{i + 1} must have #{n} elements" unless row.length == n
      end
      @matrix.flatten.each do |v|
        @errors << "All matrix entries must be finite numbers" unless v.finite?
      end
    end

    def solve_2x2
      a, b = @matrix[0]
      c, d = @matrix[1]

      trace = a + d
      det = a * d - b * c
      discriminant = trace**2 - 4 * det

      eigenvalues = if discriminant >= 0
        sqrt_disc = ::Math.sqrt(discriminant)
        [
          (trace + sqrt_disc) / 2.0,
          (trace - sqrt_disc) / 2.0
        ]
      else
        sqrt_disc = ::Math.sqrt(-discriminant)
        [
          { real: trace / 2.0, imaginary: sqrt_disc / 2.0 },
          { real: trace / 2.0, imaginary: -sqrt_disc / 2.0 }
        ]
      end

      eigenvectors = compute_eigenvectors_2x2(eigenvalues, a, b, c, d)

      {
        eigenvalues: eigenvalues,
        eigenvectors: eigenvectors,
        trace: trace,
        determinant: det,
        discriminant: discriminant,
        characteristic_polynomial: format_char_poly_2x2(trace, det),
        eigenvalue_display: format_eigenvalues(eigenvalues)
      }
    end

    def compute_eigenvectors_2x2(eigenvalues, a, b, c, d)
      eigenvalues.map do |lam|
        next { display: "complex eigenvector" } if lam.is_a?(Hash)

        # (A - lambda*I)v = 0
        r1 = a - lam
        r2 = b

        if r2.abs > 1e-12
          vec = [ -r2, r1 ]
        elsif c.abs > 1e-12
          vec = [ d - lam, -c ]
        else
          vec = [ 1, 0 ]
        end

        # Normalize
        mag = ::Math.sqrt(vec[0]**2 + vec[1]**2)
        vec = vec.map { |v| v / mag } if mag > 1e-12

        { vector: vec, display: format_eigenvector(vec) }
      end
    end

    def solve_3x3
      a = @matrix

      # Characteristic polynomial: -lambda^3 + tr*lambda^2 - k*lambda + det = 0
      # Using the formula for 3x3 eigenvalues
      tr = a[0][0] + a[1][1] + a[2][2]

      # Sum of 2x2 minors along diagonal
      k = a[0][0] * a[1][1] - a[0][1] * a[1][0] +
          a[0][0] * a[2][2] - a[0][2] * a[2][0] +
          a[1][1] * a[2][2] - a[1][2] * a[2][1]

      det = determinant_3x3(a)

      # Solve cubic: lambda^3 - tr*lambda^2 + k*lambda - det = 0
      eigenvalues = solve_cubic(1, -tr, k, -det)

      eigenvectors = eigenvalues.map do |lam|
        if lam.is_a?(Hash)
          { display: "complex eigenvector" }
        else
          vec = compute_eigenvector_3x3(a, lam)
          { vector: vec, display: format_eigenvector(vec) }
        end
      end

      {
        eigenvalues: eigenvalues,
        eigenvectors: eigenvectors,
        trace: tr,
        determinant: det,
        characteristic_polynomial: format_char_poly_3x3(tr, k, det),
        eigenvalue_display: format_eigenvalues(eigenvalues)
      }
    end

    def determinant_3x3(m)
      m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) -
        m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) +
        m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0])
    end

    def solve_cubic(a, b, c, d)
      # Normalize: x^3 + px^2 + qx + r = 0
      p = b.to_f / a
      q = c.to_f / a
      r = d.to_f / a

      # Depressed cubic: t^3 + pt2 + qt + r2 = 0 where t = x - p/3
      q2 = (3 * q - p**2) / 9.0
      r2 = (9 * p * q - 27 * r - 2 * p**3) / 54.0
      disc = q2**3 + r2**2

      if disc >= 0
        # One real root, two complex conjugate
        s = cbrt(r2 + ::Math.sqrt(disc))
        t = cbrt(r2 - ::Math.sqrt(disc))

        real_root = s + t - p / 3.0

        if disc.abs < 1e-10
          # All real, at least two equal
          root2 = -(s + t) / 2.0 - p / 3.0
          [ real_root, root2, root2 ]
        else
          real_part = -(s + t) / 2.0 - p / 3.0
          imag_part = (s - t) * ::Math.sqrt(3) / 2.0
          [
            real_root,
            { real: real_part, imaginary: imag_part },
            { real: real_part, imaginary: -imag_part }
          ]
        end
      else
        # Three distinct real roots
        theta = ::Math.acos(r2 / ::Math.sqrt(-(q2**3)))
        mag = 2.0 * ::Math.sqrt(-q2)
        [
          mag * ::Math.cos(theta / 3.0) - p / 3.0,
          mag * ::Math.cos((theta + 2 * ::Math::PI) / 3.0) - p / 3.0,
          mag * ::Math.cos((theta + 4 * ::Math::PI) / 3.0) - p / 3.0
        ]
      end
    end

    def cbrt(x)
      x >= 0 ? x**(1.0 / 3) : -((-x)**(1.0 / 3))
    end

    def compute_eigenvector_3x3(a, lam)
      # Build A - lambda*I
      m = a.map.with_index { |row, i| row.map.with_index { |val, j| i == j ? val - lam : val } }

      # Find the null space by trying rows
      # Use cross product of two rows of (A - lambda*I)
      rows = m.map { |r| r.dup }

      # Try cross products of pairs of rows
      best = nil
      best_mag = 0
      [ [ 0, 1 ], [ 0, 2 ], [ 1, 2 ] ].each do |i, j|
        v = cross3(rows[i], rows[j])
        mag = ::Math.sqrt(v.map { |c| c**2 }.sum)
        if mag > best_mag
          best = v
          best_mag = mag
        end
      end

      if best_mag > 1e-12
        best.map { |c| c / best_mag }
      else
        # Fallback: find a non-zero column from the cofactor matrix
        [ 1.0, 0.0, 0.0 ]
      end
    end

    def cross3(a, b)
      [
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0]
      ]
    end

    def format_eigenvalues(eigenvalues)
      eigenvalues.map do |lam|
        if lam.is_a?(Hash)
          sign = lam[:imaginary] >= 0 ? "+" : "-"
          "#{format_num(lam[:real])} #{sign} #{format_num(lam[:imaginary].abs)}i"
        else
          format_num(lam)
        end
      end.join(", ")
    end

    def format_eigenvector(vec)
      components = vec.map { |c| format_num(c) }
      "[#{components.join(', ')}]"
    end

    def format_char_poly_2x2(trace, det)
      "\u03BB\u00B2 - #{format_num(trace)}\u03BB + #{format_num(det)} = 0"
    end

    def format_char_poly_3x3(trace, k, det)
      "\u03BB\u00B3 - #{format_num(trace)}\u03BB\u00B2 + #{format_num(k)}\u03BB - #{format_num(det)} = 0"
    end

    def format_num(n)
      n = 0.0 if n.abs < 1e-10
      if n == n.to_i.to_f && n.abs < 1e12
        n.to_i.to_s
      else
        ("%.6g" % n)
      end
    end
  end
end
