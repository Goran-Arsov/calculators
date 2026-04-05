module Math
  class MeanMedianModeCalculator
    attr_reader :errors

    def initialize(values:)
      @raw_values = values.to_s
      @values = parse_values(@raw_values)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      sorted = @values.sort
      count = sorted.size
      sum = sorted.sum
      mean = sum / count.to_f

      median = if count.odd?
                 sorted[count / 2]
      else
                 (sorted[count / 2 - 1] + sorted[count / 2]) / 2.0
      end

      mode_result = compute_mode(sorted)
      range = sorted.last - sorted.first

      variance = sorted.sum { |v| (v - mean)**2 } / count.to_f
      std_dev = ::Math.sqrt(variance)

      sample_variance = count > 1 ? sorted.sum { |v| (v - mean)**2 } / (count - 1).to_f : 0.0
      sample_std_dev = count > 1 ? ::Math.sqrt(sample_variance) : 0.0

      {
        valid: true,
        count: count,
        sum: sum.round(4),
        mean: mean.round(4),
        median: median.round(4),
        mode: mode_result,
        range: range.round(4),
        min: sorted.first.round(4),
        max: sorted.last.round(4),
        std_dev: std_dev.round(4),
        sample_std_dev: sample_std_dev.round(4),
        variance: variance.round(4),
        sample_variance: sample_variance.round(4)
      }
    end

    private

    def parse_values(raw)
      raw.split(",").map { |v| Float(v.strip) }
    rescue ArgumentError, TypeError
      []
    end

    def validate!
      @errors << "Please enter at least 1 comma-separated number" if @values.empty?
      @errors << "Invalid number format detected" if @raw_values.present? && @values.empty?
    end

    def compute_mode(sorted)
      freq = sorted.tally
      max_freq = freq.values.max
      return "No mode" if max_freq == 1

      modes = freq.select { |_, v| v == max_freq }.keys.sort
      modes.map { |m| m.round(4) }
    end
  end
end
