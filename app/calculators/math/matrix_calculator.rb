module Math
  class MatrixCalculator
    attr_reader :errors

    def initialize(matrix_a:, matrix_b: nil, operation: "add")
      @matrix_a = parse_matrix(matrix_a)
      @matrix_b = parse_matrix(matrix_b)
      @operation = operation.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = case @operation
               when "add" then matrix_add(@matrix_a, @matrix_b)
               when "subtract" then matrix_subtract(@matrix_a, @matrix_b)
               when "multiply" then matrix_multiply(@matrix_a, @matrix_b)
               when "determinant_a" then { scalar: determinant(@matrix_a) }
               when "determinant_b" then { scalar: determinant(@matrix_b) }
               when "transpose_a" then { matrix: transpose(@matrix_a) }
               when "transpose_b" then { matrix: transpose(@matrix_b) }
               end

      if result.key?(:scalar)
        { valid: true, operation: @operation, scalar: result[:scalar].round(4) }
      else
        {
          valid: true,
          operation: @operation,
          result_matrix: result[:matrix].map { |row| row.map { |v| v.round(4) } }
        }
      end
    end

    private

    def parse_matrix(raw)
      return nil if raw.nil? || raw.to_s.strip.empty?

      raw.to_s.strip.split(";").map do |row|
        row.strip.split(",").map { |v| Float(v.strip) }
      end
    rescue ArgumentError, TypeError
      nil
    end

    def validate!
      @errors << "Invalid operation" unless %w[add subtract multiply determinant_a determinant_b transpose_a transpose_b].include?(@operation)
      @errors << "Matrix A is required" if @matrix_a.nil? || @matrix_a.empty?

      return if @errors.any?

      unless rectangular?(@matrix_a)
        @errors << "Matrix A rows must have equal length"
        return
      end

      if %w[add subtract multiply].include?(@operation) || %w[determinant_b transpose_b].include?(@operation)
        if %w[determinant_b transpose_b].include?(@operation)
          @errors << "Matrix B is required" if @matrix_b.nil? || @matrix_b.empty?
          if @matrix_b && !rectangular?(@matrix_b)
            @errors << "Matrix B rows must have equal length"
          end
        end

        if %w[add subtract].include?(@operation)
          @errors << "Matrix B is required" if @matrix_b.nil? || @matrix_b.empty?
          if @matrix_b && rectangular?(@matrix_b)
            if @matrix_a.size != @matrix_b.size || @matrix_a.first.size != @matrix_b.first.size
              @errors << "Matrices must have the same dimensions for addition/subtraction"
            end
          elsif @matrix_b
            @errors << "Matrix B rows must have equal length"
          end
        end

        if @operation == "multiply"
          @errors << "Matrix B is required" if @matrix_b.nil? || @matrix_b.empty?
          if @matrix_b && rectangular?(@matrix_b)
            if @matrix_a.first.size != @matrix_b.size
              @errors << "Number of columns in A must equal number of rows in B for multiplication"
            end
          elsif @matrix_b
            @errors << "Matrix B rows must have equal length"
          end
        end
      end

      if @operation == "determinant_a" && @matrix_a
        unless @matrix_a.size == @matrix_a.first.size
          @errors << "Matrix must be square to compute determinant"
        end
      end

      if @operation == "determinant_b" && @matrix_b
        unless @matrix_b.size == @matrix_b.first.size
          @errors << "Matrix must be square to compute determinant"
        end
      end
    end

    def rectangular?(matrix)
      return false if matrix.nil? || matrix.empty?
      matrix.all? { |row| row.size == matrix.first.size }
    end

    def matrix_add(a, b)
      result = a.each_with_index.map do |row, i|
        row.each_with_index.map { |val, j| val + b[i][j] }
      end
      { matrix: result }
    end

    def matrix_subtract(a, b)
      result = a.each_with_index.map do |row, i|
        row.each_with_index.map { |val, j| val - b[i][j] }
      end
      { matrix: result }
    end

    def matrix_multiply(a, b)
      rows_a = a.size
      cols_b = b.first.size
      result = Array.new(rows_a) { Array.new(cols_b, 0.0) }

      rows_a.times do |i|
        cols_b.times do |j|
          a[i].size.times do |k|
            result[i][j] += a[i][k] * b[k][j]
          end
        end
      end
      { matrix: result }
    end

    def transpose(matrix)
      matrix.first.size.times.map do |j|
        matrix.size.times.map { |i| matrix[i][j] }
      end
    end

    def determinant(matrix)
      n = matrix.size
      return matrix[0][0] if n == 1
      return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0] if n == 2

      det = 0.0
      n.times do |col|
        sub = submatrix(matrix, 0, col)
        sign = col.even? ? 1 : -1
        det += sign * matrix[0][col] * determinant(sub)
      end
      det
    end

    def submatrix(matrix, skip_row, skip_col)
      matrix.each_with_index.filter_map do |row, i|
        next if i == skip_row
        row.each_with_index.filter_map { |val, j| val unless j == skip_col }
      end
    end
  end
end
