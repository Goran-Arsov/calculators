require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  # --- Validations ---

  test "valid photo is valid" do
    photo = Photo.new(filename: "x.jpg", byte_size: 10)
    assert photo.valid?
  end

  test "requires filename" do
    photo = Photo.new(byte_size: 10)
    assert_not photo.valid?
    assert_includes photo.errors[:filename], "can't be blank"
  end

  test "requires byte_size" do
    photo = Photo.new(filename: "x.jpg")
    assert_not photo.valid?
    assert_includes photo.errors[:byte_size], "can't be blank"
  end

  test "filename must be unique" do
    Photo.create!(filename: "dup.jpg", byte_size: 1)
    duplicate = Photo.new(filename: "dup.jpg", byte_size: 2)
    assert_not duplicate.valid?
  end

  # --- Tag normalization ---

  test "normalize_tags trims whitespace" do
    photo = Photo.create!(filename: "1.jpg", byte_size: 1, tags: [ "  sunset  ", "beach " ])
    assert_equal [ "sunset", "beach" ], photo.tags
  end

  test "normalize_tags downcases" do
    photo = Photo.create!(filename: "2.jpg", byte_size: 1, tags: [ "Landscape", "BEACH" ])
    assert_equal [ "landscape", "beach" ], photo.tags
  end

  test "normalize_tags removes empty strings" do
    photo = Photo.create!(filename: "3.jpg", byte_size: 1, tags: [ "a", "", "  ", "b" ])
    assert_equal [ "a", "b" ], photo.tags
  end

  test "normalize_tags deduplicates after downcasing" do
    photo = Photo.create!(filename: "4.jpg", byte_size: 1, tags: [ "cat", "Cat", "CAT" ])
    assert_equal [ "cat" ], photo.tags
  end

  test "normalize_tags handles nil" do
    photo = Photo.create!(filename: "5.jpg", byte_size: 1, tags: nil)
    assert_equal [], photo.tags
  end

  # --- Tag validation ---

  test "accepts up to MAX_TAGS tags" do
    tags = (1..Photo::MAX_TAGS).map { |i| "t#{i}" }
    photo = Photo.new(filename: "m.jpg", byte_size: 1, tags: tags)
    assert photo.valid?
  end

  test "rejects more than MAX_TAGS tags" do
    tags = (1..(Photo::MAX_TAGS + 1)).map { |i| "t#{i}" }
    photo = Photo.new(filename: "o.jpg", byte_size: 1, tags: tags)
    assert_not photo.valid?
    assert_includes photo.errors[:tags].first, "or fewer"
  end

  # --- Scope: with_tag ---

  test "with_tag returns only photos carrying that tag" do
    a = Photo.create!(filename: "a.jpg", byte_size: 1, tags: [ "sunset", "beach" ])
    b = Photo.create!(filename: "b.jpg", byte_size: 1, tags: [ "mountain" ])
    c = Photo.create!(filename: "c.jpg", byte_size: 1, tags: [ "beach" ])

    results = Photo.with_tag("beach").where(id: [ a.id, b.id, c.id ])
    assert_includes results, a
    assert_includes results, c
    assert_not_includes results, b
  end

  # --- Class method: all_tags ---

  test "all_tags returns sorted unique tags across all photos" do
    Photo.create!(filename: "a1.jpg", byte_size: 1, tags: [ "zulu", "alpha" ])
    Photo.create!(filename: "b1.jpg", byte_size: 1, tags: [ "alpha", "bravo" ])
    Photo.create!(filename: "c1.jpg", byte_size: 1, tags: [])

    tags = Photo.all_tags
    assert_equal [ "alpha", "bravo", "zulu" ], tags
  end

  test "all_tags excludes photos with empty tag arrays" do
    Photo.create!(filename: "empty.jpg", byte_size: 1, tags: [])
    assert_equal [], Photo.all_tags
  end
end
