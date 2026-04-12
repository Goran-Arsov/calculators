module Health
  class BloodTypeCompatibilityCalculator
    attr_reader :errors

    BLOOD_TYPES = %w[A+ A- B+ B- AB+ AB- O+ O-].freeze

    # Donor -> can donate to these recipients
    DONATION_COMPATIBILITY = {
      "O-"  => %w[A+ A- B+ B- AB+ AB- O+ O-],
      "O+"  => %w[A+ B+ AB+ O+],
      "A-"  => %w[A+ A- AB+ AB-],
      "A+"  => %w[A+ AB+],
      "B-"  => %w[B+ B- AB+ AB-],
      "B+"  => %w[B+ AB+],
      "AB-" => %w[AB+ AB-],
      "AB+" => %w[AB+]
    }.freeze

    # Recipient -> can receive from these donors
    RECEIVING_COMPATIBILITY = {
      "O-"  => %w[O-],
      "O+"  => %w[O- O+],
      "A-"  => %w[O- A-],
      "A+"  => %w[O- O+ A- A+],
      "B-"  => %w[O- B-],
      "B+"  => %w[O- O+ B- B+],
      "AB-" => %w[O- A- B- AB-],
      "AB+" => %w[O- O+ A- A+ B- B+ AB- AB+]
    }.freeze

    # Plasma compatibility is roughly the reverse of RBC
    PLASMA_DONATION = {
      "AB+" => %w[A+ A- B+ B- AB+ AB- O+ O-],
      "AB-" => %w[A- B- AB- O-],
      "A+"  => %w[A+ O+],
      "A-"  => %w[A+ A- O+ O-],
      "B+"  => %w[B+ O+],
      "B-"  => %w[B+ B- O+ O-],
      "O+"  => %w[O+],
      "O-"  => %w[O+ O-]
    }.freeze

    POPULATION_FREQUENCY = {
      "O+" => 37.4, "O-" => 6.6,
      "A+" => 35.7, "A-" => 6.3,
      "B+" => 8.5, "B-" => 1.5,
      "AB+" => 3.4, "AB-" => 0.6
    }.freeze

    def initialize(blood_type:, mode: "both")
      @blood_type = blood_type.to_s.strip.upcase
      @mode = mode.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      can_donate_to = DONATION_COMPATIBILITY[@blood_type]
      can_receive_from = RECEIVING_COMPATIBILITY[@blood_type]
      plasma_donate_to = PLASMA_DONATION[@blood_type]

      {
        valid: true,
        blood_type: @blood_type,
        can_donate_to: can_donate_to,
        can_receive_from: can_receive_from,
        plasma_can_donate_to: plasma_donate_to,
        is_universal_donor: @blood_type == "O-",
        is_universal_recipient: @blood_type == "AB+",
        is_universal_plasma_donor: @blood_type == "AB+",
        population_frequency: POPULATION_FREQUENCY[@blood_type],
        compatibility_matrix: build_compatibility_matrix,
        antigen_info: antigen_info,
        special_notes: special_notes
      }
    end

    private

    def build_compatibility_matrix
      BLOOD_TYPES.map do |donor|
        BLOOD_TYPES.map do |recipient|
          {
            donor: donor,
            recipient: recipient,
            compatible: DONATION_COMPATIBILITY[donor].include?(recipient)
          }
        end
      end.flatten
    end

    def antigen_info
      type = @blood_type
      has_a = type.include?("A")
      has_b = type.include?("B")
      rh_positive = type.include?("+")

      antigens = []
      antigens << "A" if has_a && !has_b
      antigens << "B" if has_b && !has_a
      antigens << "A and B" if has_a && has_b
      antigens << "Rh (D)" if rh_positive

      antibodies = []
      antibodies << "Anti-B" if has_a && !has_b
      antibodies << "Anti-A" if has_b && !has_a
      antibodies << "Anti-A and Anti-B" if !has_a && !has_b && !type.start_with?("AB")

      {
        antigens_present: antigens.any? ? antigens.join(", ") : "None (Type O)",
        antibodies_present: antibodies.any? ? antibodies.join(", ") : "None (Type AB)",
        rh_factor: rh_positive ? "Positive" : "Negative"
      }
    end

    def special_notes
      notes = []
      case @blood_type
      when "O-"
        notes << "Universal red blood cell donor - can donate to all blood types."
        notes << "Only 6.6% of the population has O- blood, making it always in high demand."
      when "O+"
        notes << "Most common blood type. Can donate red cells to any Rh-positive type."
      when "AB+"
        notes << "Universal recipient - can receive red blood cells from any blood type."
        notes << "Universal plasma donor - AB plasma can be given to any blood type."
      when "AB-"
        notes << "Rarest common blood type at only 0.6% of the population."
        notes << "Universal plasma donor for Rh-negative recipients."
      end
      notes
    end

    def validate!
      unless BLOOD_TYPES.include?(@blood_type)
        @errors << "Blood type must be one of: #{BLOOD_TYPES.join(', ')}"
      end
    end
  end
end
