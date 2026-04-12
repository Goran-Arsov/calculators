module Math
  class SetOperationsCalculator
    OPERATIONS = %w[union intersection difference symmetric_difference complement power_set cardinality all].freeze
    MAX_SET_SIZE = 50
    MAX_POWER_SET_SIZE = 15

    attr_reader :errors

    def initialize(set_a:, set_b: "", universal_set: "", operation: "all")
      @set_a = parse_set(set_a)
      @set_b = parse_set(set_b)
      @universal_set = parse_set(universal_set)
      @operation = operation.to_s.strip.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @operation == "all"
        compute_all
      else
        result = compute_operation(@operation)
        result.merge(
          valid: true,
          operation: @operation,
          set_a: @set_a.sort,
          set_b: @set_b.sort
        )
      end
    end

    private

    def parse_set(input)
      case input
      when Array
        input.map { |v| v.to_s.strip }.reject(&:empty?).uniq
      when String
        # Remove surrounding braces if present
        clean = input.to_s.strip.gsub(/\A\{|\}\z/, "")
        clean.split(",").map(&:strip).reject(&:empty?).uniq
      else
        []
      end
    end

    def validate!
      @errors << "Set A cannot be empty" if @set_a.empty? && @operation != "cardinality"
      @errors << "Unsupported operation '#{@operation}'" unless OPERATIONS.include?(@operation)
      @errors << "Set A has too many elements (max #{MAX_SET_SIZE})" if @set_a.length > MAX_SET_SIZE

      needs_b = %w[union intersection difference symmetric_difference]
      if needs_b.include?(@operation) || @operation == "all"
        @errors << "Set B has too many elements (max #{MAX_SET_SIZE})" if @set_b.length > MAX_SET_SIZE
      end

      if (@operation == "power_set" || @operation == "all") && @set_a.length > MAX_POWER_SET_SIZE
        @errors << "Set A is too large for power set computation (max #{MAX_POWER_SET_SIZE} elements)"
      end

      if @operation == "complement" && @universal_set.empty?
        @errors << "Universal set is required for complement operation"
      end
    end

    def compute_all
      results = {}

      results[:union] = compute_union
      results[:intersection] = compute_intersection
      results[:difference_a_minus_b] = compute_difference(@set_a, @set_b)
      results[:difference_b_minus_a] = compute_difference(@set_b, @set_a)
      results[:symmetric_difference] = compute_symmetric_difference
      results[:cardinality_a] = @set_a.length
      results[:cardinality_b] = @set_b.length

      if @set_a.length <= MAX_POWER_SET_SIZE
        results[:power_set_a] = compute_power_set(@set_a)
        results[:power_set_a_size] = results[:power_set_a].length
      end

      if @universal_set.any?
        results[:complement_a] = compute_complement(@set_a)
        results[:complement_b] = compute_complement(@set_b)
      end

      results[:is_subset_a_of_b] = (@set_a - @set_b).empty?
      results[:is_subset_b_of_a] = (@set_b - @set_a).empty?
      results[:are_disjoint] = (@set_a & @set_b).empty?
      results[:are_equal] = @set_a.sort == @set_b.sort

      {
        valid: true,
        operation: "all",
        set_a: @set_a.sort,
        set_b: @set_b.sort,
        universal_set: @universal_set.sort,
        results: results
      }
    end

    def compute_operation(op)
      case op
      when "union"
        result = compute_union
        { result: result.sort, display: format_set(result), cardinality: result.length }
      when "intersection"
        result = compute_intersection
        { result: result.sort, display: format_set(result), cardinality: result.length }
      when "difference"
        result = compute_difference(@set_a, @set_b)
        { result: result.sort, display: format_set(result), cardinality: result.length }
      when "symmetric_difference"
        result = compute_symmetric_difference
        { result: result.sort, display: format_set(result), cardinality: result.length }
      when "complement"
        result = compute_complement(@set_a)
        { result: result.sort, display: format_set(result), cardinality: result.length }
      when "power_set"
        result = compute_power_set(@set_a)
        { result: result.map(&:sort), display: format_power_set(result), cardinality: result.length }
      when "cardinality"
        { result: @set_a.length, display: "|A| = #{@set_a.length}" }
      end
    end

    def compute_union
      (@set_a | @set_b)
    end

    def compute_intersection
      (@set_a & @set_b)
    end

    def compute_difference(a, b)
      (a - b)
    end

    def compute_symmetric_difference
      (@set_a - @set_b) | (@set_b - @set_a)
    end

    def compute_complement(set)
      @universal_set - set
    end

    def compute_power_set(set)
      result = [[]]
      set.each do |element|
        result += result.map { |subset| subset + [element] }
      end
      result
    end

    def format_set(set)
      "{#{set.sort.join(', ')}}"
    end

    def format_power_set(sets)
      inner = sets.map { |s| format_set(s) }.join(", ")
      "{#{inner}}"
    end
  end
end
