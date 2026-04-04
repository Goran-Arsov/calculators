module Physics
  class ElementMassCalculator
    attr_reader :errors

    def initialize(symbol:, volume:)
      @symbol = symbol.to_s.strip
      @volume = volume.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      element = ElementData.find_by_symbol(@symbol)
      density = element[:density]
      mass = density * @volume

      {
        valid: true,
        element: element[:name],
        symbol: element[:symbol],
        density: density,
        volume: @volume.round(6),
        mass: mass.round(6)
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
      @errors << "Volume must be positive" if @volume <= 0
    end
  end
end
