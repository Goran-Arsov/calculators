class CalculatorRating < ApplicationRecord
  validates :calculator_slug, presence: true
  validates :direction, presence: true, inclusion: { in: %w[up down] }
  validates :ip_hash, presence: true, uniqueness: { scope: :calculator_slug, message: "has already rated this calculator" }

  scope :for_calculator, ->(slug) { where(calculator_slug: slug) }
  scope :thumbs_up, -> { where(direction: "up") }
  scope :thumbs_down, -> { where(direction: "down") }

  def self.counts_for(slug)
    counts = for_calculator(slug).group(:direction).count
    { up: counts["up"] || 0, down: counts["down"] || 0 }
  end

  def self.rating_for_schema(slug)
    counts = counts_for(slug)
    total = counts[:up] + counts[:down]
    return nil if total.zero?

    ratio = counts[:up].to_f / total
    value = (ratio * 4 + 1).round(1)

    { rating_value: value, rating_count: total }
  end
end
