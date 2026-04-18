require "test_helper"

class BlogPostTest < ActiveSupport::TestCase
  # --- Validations ---

  test "valid blog post is valid" do
    post = BlogPost.new(
      title: "Test Title",
      slug: "test-title",
      body: "<p>Body content</p>",
      excerpt: "Short excerpt"
    )
    assert post.valid?
  end

  test "requires title" do
    post = BlogPost.new(slug: "s", body: "b", excerpt: "e")
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "requires slug" do
    post = BlogPost.new(title: "t", body: "b", excerpt: "e")
    assert_not post.valid?
    assert_includes post.errors[:slug], "can't be blank"
  end

  test "requires body" do
    post = BlogPost.new(title: "t", slug: "s", excerpt: "e")
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "requires excerpt" do
    post = BlogPost.new(title: "t", slug: "s", body: "b")
    assert_not post.valid?
    assert_includes post.errors[:excerpt], "can't be blank"
  end

  test "slug must be unique" do
    BlogPost.create!(title: "First", slug: "unique-slug", body: "b", excerpt: "e")
    duplicate = BlogPost.new(title: "Second", slug: "unique-slug", body: "b", excerpt: "e")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  # --- Scope: published ---

  test "published scope returns posts with published_at in the past" do
    past_post = BlogPost.create!(title: "Past", slug: "past", body: "b", excerpt: "e", published_at: 1.day.ago)
    assert_includes BlogPost.published, past_post
  end

  test "published scope excludes posts with future published_at" do
    future_post = BlogPost.create!(title: "Future", slug: "future", body: "b", excerpt: "e", published_at: 1.day.from_now)
    assert_not_includes BlogPost.published, future_post
  end

  test "published scope excludes posts with nil published_at" do
    draft_post = BlogPost.create!(title: "Draft", slug: "draft", body: "b", excerpt: "e", published_at: nil)
    assert_not_includes BlogPost.published, draft_post
  end

  # --- Scope: by_category ---

  test "by_category filters posts by category when given" do
    finance = BlogPost.create!(title: "Finance", slug: "finance-post", body: "b", excerpt: "e", category: "finance")
    math = BlogPost.create!(title: "Math", slug: "math-post", body: "b", excerpt: "e", category: "math")

    results = BlogPost.by_category("finance")
    assert_includes results, finance
    assert_not_includes results, math
  end

  test "by_category returns all posts when nil" do
    finance = BlogPost.create!(title: "Finance", slug: "finance-all", body: "b", excerpt: "e", category: "finance")
    math = BlogPost.create!(title: "Math", slug: "math-all", body: "b", excerpt: "e", category: "math")

    results = BlogPost.by_category(nil)
    assert_includes results, finance
    assert_includes results, math
  end

  test "by_category returns all posts when empty string" do
    post = BlogPost.create!(title: "Any", slug: "any-cat", body: "b", excerpt: "e", category: "finance")

    results = BlogPost.by_category("")
    assert_includes results, post
  end

  # --- Scope: recent ---

  test "recent orders posts by published_at descending" do
    old = BlogPost.create!(title: "Old", slug: "old", body: "b", excerpt: "e", published_at: 3.days.ago)
    new_post = BlogPost.create!(title: "New", slug: "new", body: "b", excerpt: "e", published_at: 1.day.ago)
    mid = BlogPost.create!(title: "Mid", slug: "mid", body: "b", excerpt: "e", published_at: 2.days.ago)

    ordered = BlogPost.recent.where(id: [ old.id, new_post.id, mid.id ])
    assert_equal [ new_post, mid, old ], ordered.to_a
  end

  # --- Instance methods ---

  test "to_param returns slug" do
    post = BlogPost.new(slug: "my-custom-slug")
    assert_equal "my-custom-slug", post.to_param
  end

  test "published? returns true for past published_at" do
    post = BlogPost.new(published_at: 1.hour.ago)
    assert post.published?
  end

  test "published? returns true for published_at equal to now" do
    post = BlogPost.new(published_at: Time.current)
    assert post.published?
  end

  test "published? returns false for future published_at" do
    post = BlogPost.new(published_at: 1.hour.from_now)
    assert_not post.published?
  end

  test "published? returns false for nil published_at" do
    post = BlogPost.new(published_at: nil)
    assert_not post.published?
  end

  # --- og_description ---

  test "og_description prefers meta_description when present" do
    post = BlogPost.new(meta_description: "Meta desc", excerpt: "Short excerpt")
    assert_equal "Meta desc", post.og_description
  end

  test "og_description falls back to excerpt when meta_description is blank" do
    post = BlogPost.new(meta_description: "", excerpt: "Short excerpt")
    assert_equal "Short excerpt", post.og_description
  end

  test "og_description falls back to excerpt when meta_description is nil" do
    post = BlogPost.new(meta_description: nil, excerpt: "Short excerpt")
    assert_equal "Short excerpt", post.og_description
  end

  # --- latest_published_update ---

  test "latest_published_update returns max updated_at across published posts" do
    newer = BlogPost.create!(title: "Newer", slug: "newer", body: "b", excerpt: "e", published_at: 1.day.ago)
    newer_ts = 10.years.from_now
    newer.update_columns(updated_at: newer_ts)

    assert_in_delta newer_ts.to_i, BlogPost.latest_published_update.to_i, 2
  end

  test "latest_published_update ignores unpublished posts" do
    baseline = BlogPost.latest_published_update
    draft = BlogPost.create!(title: "Draft", slug: "draft-latest", body: "b", excerpt: "e", published_at: nil)
    draft.update_columns(updated_at: 10.years.from_now)

    assert_equal baseline&.to_i, BlogPost.latest_published_update&.to_i
  end
end
