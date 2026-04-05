class UserFormula < ApplicationRecord
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 500 }
  validates :formula_json, presence: true
  validates :category, presence: true, inclusion: { in: %w[finance math physics health construction everyday] }
  validates :author_name, presence: true, length: { maximum: 50 }
  validates :author_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :status, inclusion: { in: %w[pending approved rejected] }

  scope :approved, -> { where(status: "approved") }
  scope :pending, -> { where(status: "pending") }
  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :recent, -> { order(created_at: :desc) }

  before_validation :generate_slug, on: :create

  def approved?
    status == "approved"
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank?
  end
end
