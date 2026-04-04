module Math
  class StandardDeviationCalculator
    attr_reader :errors

    def initialize(values:)
      @raw_values = values.to_s
      @values = parse_values(@raw_values)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      count = @values.size
      mean = @values.sum / count
      variance = @values.sum { |v| (v - mean)**2 } / count
      std_dev = ::Math.sqrt(variance)

      sample_variance = count > 1 ? @values.sum { |v| (v - mean)**2 } / (count - 1) : 0.0
      sample_std_dev = count > 1 ? ::Math.sqrt(sample_variance) : 0.0

      sorted = @values.sort
      min = sorted.first
      max = sorted.last
      range = max - min

      {
        valid: true,
        count: count,
        mean: mean.round(4),
        variance: variance.round(4),
        std_dev: std_dev.round(4),
        sample_variance: sample_variance.round(4),
        sample_std_dev: sample_std_dev.round(4),
        min: min.round(4),
        max: max.round(4),
        range: range.round(4)
      }
    end

    private

    def parse_values(raw)
      raw.split(",").map { |v| Float(v.strip) }
    rescue ArgumentError, TypeError
      []
    end

    def validate!
      @errors << "Please enter at least 2 comma-separated numbers" if @values.size < 2
      @errors << "Invalid number format detected" if @raw_values.present? && @values.empty?
    end
  end
end
