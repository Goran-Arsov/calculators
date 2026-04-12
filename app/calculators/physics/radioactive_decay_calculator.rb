module Physics
  class RadioactiveDecayCalculator
    attr_reader :errors

    VALID_MODES = %w[find_remaining find_time find_half_life].freeze

    def initialize(mode:, initial_amount: nil, half_life: nil, time: nil, remaining_amount: nil)
      @mode = mode.to_s.downcase.strip
      @initial_amount = initial_amount.present? ? initial_amount.to_f : nil
      @half_life = half_life.present? ? half_life.to_f : nil
      @time = time.present? ? time.to_f : nil
      @remaining_amount = remaining_amount.present? ? remaining_amount.to_f : nil
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "find_remaining"
        calculate_remaining
      when "find_time"
        calculate_time
      when "find_half_life"
        calculate_half_life
      end
    end

    private

    def calculate_remaining
      # N(t) = N0 * (1/2)^(t/t_half)
      half_lives_elapsed = @time / @half_life
      remaining = @initial_amount * (0.5**half_lives_elapsed)

      # Decay constant lambda = ln(2) / t_half
      decay_constant = ::Math.log(2) / @half_life

      # Activity A = lambda * N (in same units as amount)
      activity = decay_constant * remaining

      # Percent remaining
      percent_remaining = (remaining / @initial_amount) * 100.0
      amount_decayed = @initial_amount - remaining

      build_result(
        initial_amount: @initial_amount,
        remaining_amount: remaining,
        half_life: @half_life,
        time: @time,
        half_lives_elapsed: half_lives_elapsed,
        decay_constant: decay_constant,
        activity: activity,
        percent_remaining: percent_remaining,
        amount_decayed: amount_decayed
      )
    end

    def calculate_time
      # N(t) = N0 * (1/2)^(t/t_half)
      # t = t_half * log2(N0/N)
      ratio = @initial_amount / @remaining_amount
      time = @half_life * (::Math.log(ratio) / ::Math.log(2))
      half_lives_elapsed = time / @half_life

      decay_constant = ::Math.log(2) / @half_life
      activity = decay_constant * @remaining_amount
      percent_remaining = (@remaining_amount / @initial_amount) * 100.0
      amount_decayed = @initial_amount - @remaining_amount

      build_result(
        initial_amount: @initial_amount,
        remaining_amount: @remaining_amount,
        half_life: @half_life,
        time: time,
        half_lives_elapsed: half_lives_elapsed,
        decay_constant: decay_constant,
        activity: activity,
        percent_remaining: percent_remaining,
        amount_decayed: amount_decayed
      )
    end

    def calculate_half_life
      # t_half = t * ln(2) / ln(N0/N)
      ratio = @initial_amount / @remaining_amount
      half_life = @time * ::Math.log(2) / ::Math.log(ratio)
      half_lives_elapsed = @time / half_life

      decay_constant = ::Math.log(2) / half_life
      activity = decay_constant * @remaining_amount
      percent_remaining = (@remaining_amount / @initial_amount) * 100.0
      amount_decayed = @initial_amount - @remaining_amount

      build_result(
        initial_amount: @initial_amount,
        remaining_amount: @remaining_amount,
        half_life: half_life,
        time: @time,
        half_lives_elapsed: half_lives_elapsed,
        decay_constant: decay_constant,
        activity: activity,
        percent_remaining: percent_remaining,
        amount_decayed: amount_decayed
      )
    end

    def build_result(initial_amount:, remaining_amount:, half_life:, time:,
                     half_lives_elapsed:, decay_constant:, activity:,
                     percent_remaining:, amount_decayed:)
      {
        valid: true,
        mode: @mode,
        initial_amount: initial_amount.round(6),
        remaining_amount: remaining_amount.round(6),
        half_life: half_life.round(6),
        time: time.round(6),
        half_lives_elapsed: half_lives_elapsed.round(4),
        decay_constant: decay_constant.round(8),
        activity: activity.round(6),
        percent_remaining: percent_remaining.round(4),
        amount_decayed: amount_decayed.round(6)
      }
    end

    def validate!
      unless VALID_MODES.include?(@mode)
        @errors << "Mode must be 'find_remaining', 'find_time', or 'find_half_life'"
        return
      end

      case @mode
      when "find_remaining"
        validate_positive(@initial_amount, "Initial amount")
        validate_positive(@half_life, "Half-life")
        validate_non_negative(@time, "Time")
      when "find_time"
        validate_positive(@initial_amount, "Initial amount")
        validate_positive(@remaining_amount, "Remaining amount")
        validate_positive(@half_life, "Half-life")
        validate_remaining_less_than_initial
      when "find_half_life"
        validate_positive(@initial_amount, "Initial amount")
        validate_positive(@remaining_amount, "Remaining amount")
        validate_positive(@time, "Time")
        validate_remaining_less_than_initial
      end
    end

    def validate_positive(value, label)
      if value.nil?
        @errors << "#{label} is required"
      elsif value <= 0
        @errors << "#{label} must be a positive number"
      end
    end

    def validate_non_negative(value, label)
      if value.nil?
        @errors << "#{label} is required"
      elsif value < 0
        @errors << "#{label} must be non-negative"
      end
    end

    def validate_remaining_less_than_initial
      return if @initial_amount.nil? || @remaining_amount.nil?

      if @remaining_amount >= @initial_amount
        @errors << "Remaining amount must be less than initial amount"
      end
    end
  end
end
