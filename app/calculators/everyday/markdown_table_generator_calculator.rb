# frozen_string_literal: true

module Everyday
  class MarkdownTableGeneratorCalculator
    attr_reader :errors

    MIN_SIZE = 1
    MAX_SIZE = 20

    def initialize(rows:, columns:, cells: [])
      @rows = rows.to_i
      @columns = columns.to_i
      @cells = normalize_cells(cells)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      markdown = generate_markdown

      {
        valid: true,
        markdown: markdown,
        row_count: @rows,
        column_count: @columns
      }
    end

    private

    def validate!
      @errors << "Rows must be between #{MIN_SIZE} and #{MAX_SIZE}" if @rows < MIN_SIZE || @rows > MAX_SIZE
      @errors << "Columns must be between #{MIN_SIZE} and #{MAX_SIZE}" if @columns < MIN_SIZE || @columns > MAX_SIZE
    end

    def normalize_cells(cells)
      return [] unless cells.is_a?(Array)

      cells.map do |row|
        if row.is_a?(Array)
          row.map(&:to_s)
        else
          [row.to_s]
        end
      end
    end

    def generate_markdown
      lines = []

      # Determine column widths for alignment
      col_widths = Array.new(@columns, 3) # minimum width of 3 for separator

      @rows.times do |r|
        @columns.times do |c|
          cell_value = cell_at(r, c)
          col_widths[c] = [col_widths[c], cell_value.length].max
        end
      end

      # Header row (first row of cells or empty)
      header_cells = @columns.times.map { |c| cell_at(0, c).ljust(col_widths[c]) }
      lines << "| #{header_cells.join(' | ')} |"

      # Separator row
      separator_cells = col_widths.map { |w| "-" * w }
      lines << "| #{separator_cells.join(' | ')} |"

      # Data rows
      (1...@rows).each do |r|
        row_cells = @columns.times.map { |c| cell_at(r, c).ljust(col_widths[c]) }
        lines << "| #{row_cells.join(' | ')} |"
      end

      lines.join("\n")
    end

    def cell_at(row, col)
      return "" unless @cells[row].is_a?(Array)

      @cells[row][col] || ""
    end
  end
end
