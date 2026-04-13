require "test_helper"
require "tempfile"
require "fileutils"

class NoteWriterTest < ActiveSupport::TestCase
  setup do
    @tmp_storage = Pathname.new(Dir.mktmpdir("note_writer_test"))
    @original_storage_method = Note.method(:storage_dir)
    tmp = @tmp_storage
    Note.define_singleton_method(:storage_dir) { tmp }
  end

  teardown do
    Note.define_singleton_method(:storage_dir, &@original_storage_method) if @original_storage_method
    FileUtils.rm_rf(@tmp_storage)
  end

  test "writes the body to disk and persists a Note with title" do
    note = NoteWriter.new(title: "Shopping List", body: "eggs\nmilk\nbread\n").call

    assert_not_nil note
    assert note.persisted?
    assert_equal "Shopping List", note.title
    assert note.filename.end_with?(".txt")
    assert_equal "eggs\nmilk\nbread\n".bytesize, note.byte_size

    on_disk = @tmp_storage.join(note.filename)
    assert File.exist?(on_disk)
    assert_equal "eggs\nmilk\nbread\n", File.read(on_disk)
  end

  test "stores title as nil when blank" do
    note = NoteWriter.new(title: "  ", body: "content").call

    assert_not_nil note
    assert_nil note.title
  end

  test "preserves non-ASCII UTF-8 content verbatim" do
    body = "héllo — café 🌱\nсвет"
    note = NoteWriter.new(title: "unicode", body: body).call

    assert_not_nil note
    on_disk = @tmp_storage.join(note.filename)
    assert_equal body, File.read(on_disk, mode: "r:UTF-8")
  end

  test "returns nil when body is blank" do
    assert_nil NoteWriter.new(title: "t", body: "").call
    assert_nil NoteWriter.new(title: "t", body: nil).call
  end

  test "returns nil when body exceeds MAX_BODY_BYTES and leaves no orphan file" do
    oversized = "x" * (NoteWriter::MAX_BODY_BYTES + 1)

    result = NoteWriter.new(title: "big", body: oversized).call

    assert_nil result
    assert_equal 0, Note.where(title: "big").count
    assert_empty Dir.glob(@tmp_storage.join("*")), "no file should be written when oversized"
  end

  # --- Update path ---

  test "update overwrites the existing file and keeps the same filename" do
    original = NoteWriter.new(title: "draft", body: "first version").call
    original_filename = original.filename

    updated = NoteWriter.new(title: "draft", body: "second version is longer", note: original).call

    assert_not_nil updated
    assert_equal original.id, updated.id
    assert_equal original_filename, updated.filename
    assert_equal "second version is longer", File.read(@tmp_storage.join(original_filename))
    assert_equal "second version is longer".bytesize, updated.byte_size
  end

  test "update applies a new title when changed" do
    note = NoteWriter.new(title: "old title", body: "content").call
    updated = NoteWriter.new(title: "new title", body: "content", note: note).call

    assert_equal "new title", updated.reload.title
  end

  test "update returns nil for blank body and leaves the existing file untouched" do
    note = NoteWriter.new(title: "keep", body: "do not touch").call

    result = NoteWriter.new(title: "keep", body: "", note: note).call

    assert_nil result
    assert_equal "do not touch", File.read(@tmp_storage.join(note.filename))
  end

  test "update returns nil for oversized body and leaves the existing file untouched" do
    note = NoteWriter.new(title: "keep", body: "small").call
    oversized = "y" * (NoteWriter::MAX_BODY_BYTES + 1)

    result = NoteWriter.new(title: "keep", body: oversized, note: note).call

    assert_nil result
    assert_equal "small", File.read(@tmp_storage.join(note.filename))
  end
end
