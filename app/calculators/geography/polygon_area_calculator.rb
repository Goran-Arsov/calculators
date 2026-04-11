# frozen_string_literal: true

module Geography
  class PolygonAreaCalculator
    attr_reader :errors

    EARTH_RADIUS_KM = 6371.0088
    MIN_VERTICES = 3

    def initialize(vertices:)
      @vertices = parse_vertices(vertices)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      area_km2 = spherical_area(@vertices).abs
      perimeter_km = spherical_perimeter(@vertices)

      {
        valid: true,
        vertex_count: @vertices.length,
        area_km2: area_km2.round(4),
        area_mi2: (area_km2 / 2.58999).round(4),
        area_hectares: (area_km2 * 100).round(3),
        area_acres: (area_km2 * 247.105).round(3),
        perimeter_km: perimeter_km.round(3),
        perimeter_miles: (perimeter_km * 0.621371).round(3)
      }
    end

    private

    def parse_vertices(input)
      return input if input.is_a?(Array) && input.all? { |v| v.is_a?(Hash) }

      input.to_s.split(/\r?\n/).map do |line|
        parts = line.strip.split(/[,\s]+/)
        next nil if parts.length < 2
        { lat: parts[0].to_f, lon: parts[1].to_f }
      end.compact
    end

    def spherical_area(vertices)
      total = 0.0
      n = vertices.length
      n.times do |i|
        a = vertices[i]
        b = vertices[(i + 1) % n]
        total += to_rad(b[:lon] - a[:lon]) *
                 (2 + Math.sin(to_rad(a[:lat])) + Math.sin(to_rad(b[:lat])))
      end
      (total * EARTH_RADIUS_KM**2 / 2.0).abs
    end

    def spherical_perimeter(vertices)
      total = 0.0
      n = vertices.length
      n.times do |i|
        a = vertices[i]
        b = vertices[(i + 1) % n]
        total += haversine(a[:lat], a[:lon], b[:lat], b[:lon])
      end
      total
    end

    def haversine(lat1, lon1, lat2, lon2)
      phi1 = to_rad(lat1)
      phi2 = to_rad(lat2)
      dphi = to_rad(lat2 - lat1)
      dlambda = to_rad(lon2 - lon1)
      a = Math.sin(dphi / 2)**2 + Math.cos(phi1) * Math.cos(phi2) * Math.sin(dlambda / 2)**2
      2 * EARTH_RADIUS_KM * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    end

    def to_rad(deg)
      deg * Math::PI / 180.0
    end

    def validate!
      if @vertices.length < MIN_VERTICES
        @errors << "At least #{MIN_VERTICES} vertices are required to form a polygon"
        return
      end
      @vertices.each_with_index do |v, i|
        unless v[:lat].between?(-90, 90)
          @errors << "Vertex #{i + 1}: latitude must be between -90 and 90"
        end
        unless v[:lon].between?(-180, 180)
          @errors << "Vertex #{i + 1}: longitude must be between -180 and 180"
        end
      end
    end
  end
end
