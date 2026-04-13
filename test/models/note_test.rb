require "test_helper"

class NoteTest < ActiveSupport::TestCase
  # --- Validations ---

  test "valid note is valid" do
    note = Note.new(filename: "abc.txt", byte_size: 10)
    assert note.valid?
  end

  test "requires filename" do
    note = Note.new(byte_size: 10)
    assert_not note.valid?
    assert_includes note.errors[:filename], "can't be blank"
  end

  test "requires byte_size" do
    note = Note.new(filename: "abc.txt")
    assert_not note.valid?
    assert_includes note.errors[:byte_size], "can't be blank"
  end

  test "filename must be unique" do
    Note.create!(filename: "dup.txt", byte_size: 1)
    duplicate = Note.new(filename: "dup.txt", byte_size: 2)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:filename], "has already been taken"
  end

  # --- Scope: sorted_by ---

  test "sorted_by latest orders by created_at descending" do
    old = Note.create!(filename: "a.txt", byte_size: 1, created_at: 2.days.ago)
    mid = Note.create!(filename: "b.txt", byte_size: 1, created_at: 1.day.ago)
    new = Note.create!(filename: "c.txt", byte_size: 1, created_at: Time.current)

    ordered = Note.sorted_by("latest").where(id: [ old.id, mid.id, new.id ]).to_a
    assert_equal [ new, mid, old ], ordered
  end

  test "sorted_by name orders alphabetically case-insensitively" do
    c = Note.create!(filename: "1.txt", title: "charlie",  byte_size: 1)
    a = Note.create!(filename: "2.txt", title: "Alpha",    byte_size: 1)
    b = Note.create!(filename: "3.txt", title: "bravo",    byte_size: 1)

    ordered = Note.sorted_by("name").where(id: [ c.id, a.id, b.id ]).to_a
    assert_equal [ a, b, c ], ordered
  end

  test "sorted_by name places nil titles last" do
    titled_a = Note.create!(filename: "1.txt", title: "Alpha", byte_size: 1)
    untitled_1 = Note.create!(filename: "2.txt", title: nil, byte_size: 1)
    titled_z = Note.create!(filename: "3.txt", title: "Zulu", byte_size: 1)
    untitled_2 = Note.create!(filename: "4.txt", title: nil, byte_size: 1)

    ordered = Note.sorted_by("name").where(id: [ titled_a.id, untitled_1.id, titled_z.id, untitled_2.id ]).to_a
    assert_equal [ titled_a, titled_z, untitled_1, untitled_2 ], ordered
  end

  test "sorted_by size orders by byte_size descending" do
    small  = Note.create!(filename: "s.txt", byte_size: 100)
    big    = Note.create!(filename: "b.txt", byte_size: 10_000)
    medium = Note.create!(filename: "m.txt", byte_size: 1_000)

    ordered = Note.sorted_by("size").where(id: [ small.id, big.id, medium.id ]).to_a
    assert_equal [ big, medium, small ], ordered
  end

  test "sorted_by with unknown key falls back to latest" do
    old = Note.create!(filename: "a.txt", byte_size: 1, created_at: 2.days.ago)
    new = Note.create!(filename: "b.txt", byte_size: 1, created_at: Time.current)

    ordered = Note.sorted_by("bogus").where(id: [ old.id, new.id ]).to_a
    assert_equal [ new, old ], ordered
  end
end
