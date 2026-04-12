require "test_helper"
require "tempfile"
require "fileutils"
require "ostruct"

class PhotoUploaderTest < ActiveSupport::TestCase
  setup do
    @tmp_storage = Pathname.new(Dir.mktmpdir("photo_uploader_test"))
    @original_storage_method = Photo.method(:storage_dir)
    tmp = @tmp_storage
    Photo.define_singleton_method(:storage_dir) { tmp }
  end

  teardown do
    Photo.define_singleton_method(:storage_dir, &@original_storage_method) if @original_storage_method
    FileUtils.rm_rf(@tmp_storage)
  end

  test "converts a large PNG to a JPG resized to max 2000px and records settings" do
    source = generate_image(3000, 4000, "png")

    photo = PhotoUploader.new(fake_upload(source, "huge.png")).call

    assert_not_nil photo
    assert photo.persisted?
    assert_equal "huge.png", photo.original_filename
    assert_equal 95, photo.jpg_quality
    assert_equal 2000, photo.max_dimension
    # Aspect ratio preserved, longest edge clamped to 2000.
    assert_equal 1500, photo.width
    assert_equal 2000, photo.height
    assert photo.byte_size > 0

    on_disk = @tmp_storage.join(photo.filename)
    assert File.exist?(on_disk), "expected converted file on disk"
    assert_equal "JPEG", identify_format(on_disk)
  ensure
    source&.close
    source&.unlink
  end

  test "leaves smaller images at their original dimensions" do
    source = generate_image(800, 600, "png")

    photo = PhotoUploader.new(fake_upload(source, "small.png")).call

    assert_not_nil photo
    assert_equal 800, photo.width
    assert_equal 600, photo.height
  ensure
    source&.close
    source&.unlink
  end

  test "strips embedded metadata (comments) from converted output" do
    source = Tempfile.new([ "with-meta", ".jpg" ])
    source.close
    system("convert", "-size", "500x500", "xc:skyblue",
      "-set", "comment", "secret-marker-xyz",
      source.path, out: File::NULL, err: File::NULL)
    source.open

    fixture_comment = `identify -format "%c" #{source.path}`.strip
    assert_equal "secret-marker-xyz", fixture_comment, "fixture should carry the comment before conversion"

    photo = PhotoUploader.new(fake_upload(source, "with-meta.jpg")).call

    on_disk = @tmp_storage.join(photo.filename)
    output_comment = `identify -format "%c" #{on_disk}`.strip
    assert_not_equal "secret-marker-xyz", output_comment, "metadata should be stripped on conversion"
  ensure
    source&.close
    source&.unlink
  end

  test "returns nil when given a non-image file" do
    junk = Tempfile.new([ "junk", ".txt" ])
    junk.write("definitely not an image")
    junk.flush

    result = PhotoUploader.new(fake_upload(junk, "junk.txt")).call

    assert_nil result
    assert_equal 0, Photo.where(original_filename: "junk.txt").count
    assert_empty Dir.glob(@tmp_storage.join("*")), "no orphan file should be left on disk"
  ensure
    junk&.close
    junk&.unlink
  end

  test "returns nil when given blank input" do
    assert_nil PhotoUploader.new(nil).call
  end

  private

  def generate_image(width, height, format)
    file = Tempfile.new([ "fixture", ".#{format}" ])
    file.close
    system("convert", "-size", "#{width}x#{height}", "xc:skyblue", file.path,
      out: File::NULL, err: File::NULL)
    file.open
    file
  end

  def fake_upload(tempfile, original_filename)
    OpenStruct.new(
      tempfile: tempfile,
      original_filename: original_filename,
      size: File.size(tempfile.path)
    )
  end

  def identify_format(path)
    `identify -format "%m" #{path}`.strip
  end
end
