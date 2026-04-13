# frozen_string_literal: true

require "securerandom"
require "fileutils"

# Writes a plain-text note to disk under storage/notes/ and records a Note row.
#
# Creates a new note when called without an existing one, or overwrites the
# file and updates the existing row when `note:` is passed.
#
# Returns the saved Note on success, or nil if the body is blank/too large or
# any write error occurs.
class NoteWriter
  MAX_BODY_BYTES = 1.megabyte

  def initialize(title:, body:, note: nil)
    @title = title.to_s
    @body = body.to_s
    @note = note
  end

  def call
    return nil if @body.empty?
    return nil if @body.bytesize > MAX_BODY_BYTES

    @note ? update_existing : create_new
  rescue StandardError => e
    Rails.logger.error("[NoteWriter] error: #{e.class}: #{e.message}")
    nil
  end

  private

  def update_existing
    File.write(@note.disk_path, @body)
    @note.update!(title: @title.presence, byte_size: File.size(@note.disk_path))
    @note
  end

  def create_new
    filename = "#{Time.current.strftime('%Y%m%d-%H%M%S')}-#{SecureRandom.hex(6)}.txt"
    output_path = Note.storage_dir.join(filename)

    File.write(output_path, @body)

    Note.create!(
      filename: filename,
      title: @title.presence,
      byte_size: File.size(output_path)
    )
  rescue StandardError
    File.delete(output_path) if defined?(output_path) && output_path && File.exist?(output_path)
    raise
  end
end
