class CalculatorRating < ApplicationRecord
  validates :calculator_slug, presence: true
  validates :direction, presence: true, inclusion: { in: %w[up down] }
  validates :ip_hash, presence: true, uniqueness: { scope: :calculator_slug, message: "has already rated this calculator" }
  validates :score, inclusion: { in: 0..5 }, allow_nil: true

  scope :for_calculator, ->(slug) { where(calculator_slug: slug) }
  scope :thumbs_up, -> { where(direction: "up") }
  scope :thumbs_down, -> { where(direction: "down") }
  scope :with_score, -> { where.not(score: nil) }

  def self.counts_for(slug)
    counts = for_calculator(slug).group(:direction).count
    { up: counts["up"] || 0, down: counts["down"] || 0 }
  end

  def self.star_stats_for(slug)
    ratings = for_calculator(slug).with_score
    count = ratings.count
    return { average: 0.0, count: 0 } if count.zero?

    average = ratings.average(:score).to_f.round(1)
    { average: average, count: count }
  end

  def self.rating_for_schema(slug)
    stats = star_stats_for(slug)
    return nil if stats[:count].zero?

    { rating_value: stats[:average], rating_count: stats[:count] }
  end
end
