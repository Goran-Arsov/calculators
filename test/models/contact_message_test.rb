require "test_helper"

class ContactMessageTest < ActiveSupport::TestCase
  test "valid contact message" do
    msg = ContactMessage.new(name: "Jane Doe", email: "jane@example.com", subject: "general", message: "Hello, this is a test message.")
    assert msg.valid?
  end

  test "requires name" do
    msg = ContactMessage.new(email: "jane@example.com", subject: "general", message: "Hello, this is a test.")
    refute msg.valid?
    assert_includes msg.errors[:name], "can't be blank"
  end

  test "requires valid email" do
    msg = ContactMessage.new(name: "Jane", email: "not-an-email", subject: "general", message: "Hello, this is a test.")
    refute msg.valid?
    assert msg.errors[:email].any?
  end

  test "requires valid subject" do
    msg = ContactMessage.new(name: "Jane", email: "jane@example.com", subject: "invalid", message: "Hello, this is a test.")
    refute msg.valid?
    assert msg.errors[:subject].any?
  end

  test "requires message of minimum length" do
    msg = ContactMessage.new(name: "Jane", email: "jane@example.com", subject: "bug", message: "Short")
    refute msg.valid?
    assert msg.errors[:message].any?
  end

  test "unread scope" do
    ContactMessage.create!(name: "A", email: "a@b.com", subject: "general", message: "Test message one")
    assert_equal 1, ContactMessage.unread.count
  end
end
