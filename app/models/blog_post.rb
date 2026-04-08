class BlogPost < ApplicationRecord
  CATEGORIES = %w[finance math physics health construction everyday general].freeze

  validates :title, :slug, :body, :excerpt, presence: true
  validates :slug, uniqueness: true
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true
  validates :excerpt, length: { maximum: 500 }

  before_save :sanitize_external_links

  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :recent, -> { order(published_at: :desc) }

  def to_param
    slug
  end

  def published?
    published_at.present? && published_at <= Time.current
  end

  private

  def sanitize_external_links
    return if body.blank?

    self.body = body.gsub(%r{<a\s([^>]*href=["']https?://[^"']*["'][^>]*)>}i) do |match|
      unless match.include?("rel=")
        match.sub(">", ' rel="noopener noreferrer">')
      else
        match
      end
    end
  end
end
