class BlogPost < ApplicationRecord
  validates :title, :slug, :body, :excerpt, presence: true
  validates :slug, uniqueness: true

  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :recent, -> { order(published_at: :desc) }

  def to_param
    slug
  end

  def published?
    published_at.present? && published_at <= Time.current
  end
end
