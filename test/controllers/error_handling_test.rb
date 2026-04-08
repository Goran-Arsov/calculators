require "test_helper"

class ErrorHandlingTest < ActionDispatch::IntegrationTest
  test "RecordNotFound renders 404 HTML via rescue_from" do
    get blog_post_url("nonexistent-slug-that-does-not-exist")
    assert_response :not_found
    assert_includes response.body, "404"
    assert_includes response.body, "CalcWise"
  end

  test "RecordNotFound renders 404 JSON via rescue_from" do
    get blog_post_url("nonexistent-slug-that-does-not-exist"), as: :json
    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "Not found", json["error"]
  end
end
