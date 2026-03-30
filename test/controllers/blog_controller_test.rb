require "test_helper"

class BlogControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get blog_url
    assert_response :success
    assert_select "h1", /Blog/
  end

  test "should get blog post" do
    post = BlogPost.create!(
      title: "Test Post",
      slug: "test-post",
      body: "<p>Test body</p>",
      excerpt: "Test excerpt",
      published_at: 1.day.ago
    )
    get blog_post_url(post.slug)
    assert_response :success
    assert_select "h1", /Test Post/
  end

  test "should 404 for nonexistent post" do
    get blog_post_url("nonexistent-post")
    assert_response :not_found
  end
end
