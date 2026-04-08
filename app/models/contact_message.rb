class ContactMessage < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, length: { maximum: 254 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true, inclusion: { in: %w[general bug suggestion feedback business] }
  validates :message, presence: true, length: { minimum: 10, maximum: 5000 }

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
end
