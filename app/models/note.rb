# frozen_string_literal: true

class Note < ApplicationRecord
  STORAGE_DIR = Rails.root.join("storage", "notes").freeze
  SORT_OPTIONS = %w[latest name size].freeze

  validates :filename, presence: true, uniqueness: true
  validates :byte_size, presence: true

  scope :sorted_by, ->(key) {
    case key
    when "name"
      order(Arel.sql("LOWER(title) ASC NULLS LAST, filename ASC"))
    when "size"
      order(byte_size: :desc)
    else
      order(created_at: :desc)
    end
  }

  before_destroy :delete_file_from_disk

  def self.storage_dir
    STORAGE_DIR.tap { |d| FileUtils.mkdir_p(d) }
  end

  def disk_path
    self.class.storage_dir.join(filename)
  end

  def exists_on_disk?
    File.exist?(disk_path)
  end

  def read_body
    File.read(disk_path) if exists_on_disk?
  end

  def body_content
    read_body.to_s
  end

  def display_title(default = "Untitled note")
    title.presence || default
  end

  def download_filename
    "#{title.presence || 'note'}.txt"
  end

  private

  def delete_file_from_disk
    File.delete(disk_path) if exists_on_disk?
  rescue Errno::ENOENT
    nil
  end
end
