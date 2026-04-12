module Finance
  class TipPoolingCalculator
    attr_reader :errors

    # staff: array of { name:, hours: } or { name:, points: }
    # total_tips: total tip amount to distribute
    # method: "hours" or "points"
    def initialize(staff:, total_tips:, method: "hours")
      @staff = staff.map do |s|
        {
          name: s[:name].to_s,
          value: s[:hours]&.to_f || s[:points]&.to_f || 0.0
        }
      end
      @total_tips = total_tips.to_f
      @method = method.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_value = @staff.sum { |s| s[:value] }

      distribution = @staff.map do |s|
        share_percent = (s[:value] / total_value) * 100.0
        tip_amount = (@total_tips * s[:value]) / total_value

        {
          name: s[:name],
          value: s[:value].round(2),
          share_percent: share_percent.round(2),
          tip_amount: tip_amount.round(2)
        }
      end

      average_tip = @total_tips / @staff.size
      highest = distribution.max_by { |d| d[:tip_amount] }
      lowest = distribution.min_by { |d| d[:tip_amount] }

      {
        valid: true,
        distribution: distribution,
        total_tips: @total_tips.round(2),
        method: @method,
        staff_count: @staff.size,
        average_tip: average_tip.round(2),
        highest_share: highest[:name],
        lowest_share: lowest[:name]
      }
    end

    private

    def validate!
      @errors << "Total tips must be positive" unless @total_tips > 0
      @errors << "At least two staff members are required" if @staff.size < 2
      @errors << "Method must be 'hours' or 'points'" unless %w[hours points].include?(@method)

      @staff.each_with_index do |s, i|
        @errors << "Staff member #{i + 1} #{@method} must be positive" unless s[:value] > 0
        @errors << "Staff member #{i + 1} name is required" if s[:name].strip.empty?
      end
    end
  end
end
