class CalculatorRating < ApplicationRecord
  validates :calculator_slug, presence: true
  validates :direction, presence: true, inclusion: { in: %w[up down] }
  validates :ip_hash, presence: true, uniqueness: { scope: :calculator_slug, message: "has already rated this calculator" }
  validates :score, presence: true, inclusion: { in: 1..5 }

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

  def self.trending(limit = 6)
    # Try last 30 days first
    recent = thumbs_up
      .where(created_at: 30.days.ago..)
      .group(:calculator_slug)
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(limit)
      .count

    # Fall back to all-time if not enough recent ratings
    if recent.size < limit
      recent = thumbs_up
        .group(:calculator_slug)
        .order(Arel.sql("COUNT(*) DESC"))
        .limit(limit)
        .count
    end

    recent.map { |slug, count| { slug: slug, count: count } }
  end

  def self.rating_for_schema(slug)
    stats = star_stats_for(slug)
    return nil if stats[:count].zero?

    { rating_value: stats[:average], rating_count: stats[:count] }
  end
end
