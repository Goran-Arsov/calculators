module Physics
  class ElementVolumeCalculator
    attr_reader :errors

    def initialize(symbol:, mass:)
      @symbol = symbol.to_s.strip
      @mass = mass.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      element = ElementData.find_by_symbol(@symbol)
      density = element[:density]
      volume = @mass / density

      {
        valid: true,
        element: element[:name],
        symbol: element[:symbol],
        density: density,
        mass: @mass.round(6),
        volume: volume.round(6)
      }
    end

    private

    def validate!
      element = ElementData.find_by_symbol(@symbol)
      if element.nil?
        @errors << "Unknown element symbol: #{@symbol}"
      elsif element[:density].nil?
        @errors << "No known density for #{element[:name]}"
      end
      @errors << "Mass must be positive" if @mass <= 0
    end
  end
end
