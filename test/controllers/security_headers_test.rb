require "test_helper"

class SecurityHeadersTest < ActionDispatch::IntegrationTest
  test "includes Referrer-Policy header" do
    get root_path
    assert_equal "strict-origin-when-cross-origin", response.headers["Referrer-Policy"]
  end

  test "includes X-Permitted-Cross-Domain-Policies header" do
    get root_path
    assert_equal "none", response.headers["X-Permitted-Cross-Domain-Policies"]
  end

  test "includes Permissions-Policy header" do
    get root_path
    assert_equal "camera=(), microphone=(), geolocation=(), payment=()", response.headers["Permissions-Policy"]
  end
end
