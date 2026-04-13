# frozen_string_literal: true

class Photo < ApplicationRecord
  STORAGE_DIR = Rails.root.join("storage", "photos").freeze
  MAX_TAGS = 10

  validates :filename, presence: true, uniqueness: true
  validates :byte_size, presence: true
  validate :tags_within_limit

  before_validation :normalize_tags
  before_destroy :delete_file_from_disk

  scope :with_tag, ->(tag) { where("? = ANY(tags)", tag) }

  def self.all_tags
    where.not(tags: []).pluck(:tags).flatten.uniq.sort
  end

  def self.storage_dir
    STORAGE_DIR.tap { |d| FileUtils.mkdir_p(d) }
  end

  def disk_path
    self.class.storage_dir.join(filename)
  end

  def exists_on_disk?
    File.exist?(disk_path)
  end

  private

  def normalize_tags
    self.tags = (tags || []).map { |t| t.to_s.strip.downcase }.reject(&:empty?).uniq
  end

  def tags_within_limit
    errors.add(:tags, "must be #{MAX_TAGS} or fewer") if tags.to_a.size > MAX_TAGS
  end

  def delete_file_from_disk
    File.delete(disk_path) if exists_on_disk?
  rescue Errno::ENOENT
    nil
  end
end
