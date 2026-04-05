require "test_helper"

class NewsletterSubscriberTest < ActiveSupport::TestCase
  test "valid subscriber" do
    sub = NewsletterSubscriber.new(email: "test@example.com")
    assert sub.valid?
  end

  test "requires email" do
    sub = NewsletterSubscriber.new(email: "")
    refute sub.valid?
    assert_includes sub.errors[:email], "can't be blank"
  end

  test "requires valid email format" do
    sub = NewsletterSubscriber.new(email: "not-an-email")
    refute sub.valid?
    assert sub.errors[:email].any?
  end

  test "enforces unique email" do
    NewsletterSubscriber.create!(email: "dup@example.com")
    sub = NewsletterSubscriber.new(email: "dup@example.com")
    refute sub.valid?
    assert_includes sub.errors[:email], "has already been taken"
  end

  test "defaults confirmed to false" do
    sub = NewsletterSubscriber.create!(email: "new@example.com")
    refute sub.confirmed?
  end
end
