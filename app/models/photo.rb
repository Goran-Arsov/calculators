# frozen_string_literal: true

class Photo < ApplicationRecord
  STORAGE_DIR = Rails.root.join("storage", "photos").freeze

  validates :filename, presence: true, uniqueness: true
  validates :byte_size, presence: true

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

  private

  def delete_file_from_disk
    File.delete(disk_path) if exists_on_disk?
  rescue Errno::ENOENT
    nil
  end
end
