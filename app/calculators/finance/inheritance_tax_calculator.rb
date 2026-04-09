module Finance
  class InheritanceTaxCalculator
    attr_reader :errors

    # Only 6 US states levy inheritance tax (as of 2024).
    # Simplified rate tables by state and relationship class.
    # Spouses are universally exempt. Children and direct descendants
    # receive generous exemptions or low rates. Siblings and unrelated
    # heirs face higher rates.
    #
    # Structure: { exemption:, rates: [[threshold, rate], ...] }
    # Rates are marginal: each pair means "up to this amount above exemption, this rate".
    STATE_TABLES = {
      "iowa" => {
        spouse:  { exemption: Float::INFINITY, rates: [] },
        child:   { exemption: Float::INFINITY, rates: [] }, # Exempt since 2021 phase-out; fully repealed 2025
        sibling: { exemption: 0, rates: [[12_500, 0.05], [12_500, 0.06], [25_000, 0.07], [Float::INFINITY, 0.08]] },
        other:   { exemption: 0, rates: [[12_500, 0.10], [12_500, 0.12], [25_000, 0.14], [Float::INFINITY, 0.15]] }
      },
      "kentucky" => {
        spouse:  { exemption: Float::INFINITY, rates: [] },
        child:   { exemption: Float::INFINITY, rates: [] },
        sibling: { exemption: 1_000, rates: [[10_000, 0.04], [10_000, 0.05], [10_000, 0.06], [10_000, 0.07], [Float::INFINITY, 0.08]] },
        other:   { exemption: 500, rates: [[10_000, 0.06], [10_000, 0.08], [10_000, 0.10], [10_000, 0.12], [10_000, 0.14], [Float::INFINITY, 0.16]] }
      },
      "maryland" => {
        spouse:  { exemption: Float::INFINITY, rates: [] },
        child:   { exemption: Float::INFINITY, rates: [] },
        sibling: { exemption: 0, rates: [[Float::INFINITY, 0.10]] },
        other:   { exemption: 0, rates: [[Float::INFINITY, 0.10]] }
      },
      "nebraska" => {
        spouse:  { exemption: Float::INFINITY, rates: [] },
        child:   { exemption: 100_000, rates: [[Float::INFINITY, 0.01]] },
        sibling: { exemption: 40_000, rates: [[Float::INFINITY, 0.11]] },
        other:   { exemption: 25_000, rates: [[Float::INFINITY, 0.15]] }
      },
      "new_jersey" => {
        spouse:  { exemption: Float::INFINITY, rates: [] },
        child:   { exemption: Float::INFINITY, rates: [] },
        sibling: { exemption: 25_000, rates: [[Float::INFINITY, 0.11]] },
        other:   { exemption: 0, rates: [[700_000, 0.15], [Float::INFINITY, 0.16]] }
      },
      "pennsylvania" => {
        spouse:  { exemption: Float::INFINITY, rates: [] },
        child:   { exemption: 0, rates: [[Float::INFINITY, 0.045]] },
        sibling: { exemption: 0, rates: [[Float::INFINITY, 0.12]] },
        other:   { exemption: 0, rates: [[Float::INFINITY, 0.15]] }
      }
    }.freeze

    VALID_STATES = (STATE_TABLES.keys + ["none"]).freeze
    VALID_RELATIONSHIPS = %w[spouse child sibling other].freeze

    def initialize(estate_value:, state: "none", relationship: "other")
      @estate_value = estate_value.to_f
      @state = state.to_s.downcase.strip
      @relationship = relationship.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @state == "none"
        return {
          valid: true,
          estate_value: @estate_value.round(2),
          exempt_amount: @estate_value.round(2),
          taxable_amount: 0.0,
          tax_rate: 0.0,
          estimated_tax: 0.0,
          effective_rate: 0.0,
          state: @state,
          relationship: @relationship
        }
      end

      table = STATE_TABLES[@state][@relationship.to_sym]
      exemption = table[:exemption]

      if exemption == Float::INFINITY
        return {
          valid: true,
          estate_value: @estate_value.round(2),
          exempt_amount: @estate_value.round(2),
          taxable_amount: 0.0,
          tax_rate: 0.0,
          estimated_tax: 0.0,
          effective_rate: 0.0,
          state: @state,
          relationship: @relationship
        }
      end

      taxable = [@estate_value - exemption, 0].max
      tax = calculate_marginal_tax(taxable, table[:rates])
      effective_rate = @estate_value > 0 ? (tax / @estate_value * 100) : 0.0
      top_rate = table[:rates].any? ? (table[:rates].last[1] * 100) : 0.0

      {
        valid: true,
        estate_value: @estate_value.round(2),
        exempt_amount: [exemption, @estate_value].min.round(2),
        taxable_amount: taxable.round(2),
        tax_rate: top_rate.round(2),
        estimated_tax: tax.round(2),
        effective_rate: effective_rate.round(2),
        state: @state,
        relationship: @relationship
      }
    end

    private

    def validate!
      @errors << "Estate value must be positive" unless @estate_value > 0
      @errors << "Invalid state" unless VALID_STATES.include?(@state)
      @errors << "Invalid relationship" unless VALID_RELATIONSHIPS.include?(@relationship)
    end

    def calculate_marginal_tax(taxable, rates)
      return 0.0 if taxable <= 0 || rates.empty?

      remaining = taxable
      total_tax = 0.0

      rates.each do |threshold, rate|
        break if remaining <= 0
        bracket_width = [threshold, remaining].min
        total_tax += bracket_width * rate
        remaining -= bracket_width
      end

      total_tax
    end
  end
end
