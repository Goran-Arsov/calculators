class NewsletterSubscriber < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :confirmed, -> { where(confirmed: true) }
  scope :recent, -> { order(created_at: :desc) }
end
