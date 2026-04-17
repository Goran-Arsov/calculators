require "test_helper"

module Admin
  class RatingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @prev_token = ENV["ADMIN_TOKEN"]
      ENV["ADMIN_TOKEN"] = "test-token"
    end

    teardown do
      ENV["ADMIN_TOKEN"] = @prev_token
    end

    # --- Login page ---

    test "login page is accessible without authentication" do
      get admin_login_path
      assert_response :success
    end

    test "login page redirects to ratings index when already signed in" do
      login_as_admin
      get admin_login_path
      assert_redirected_to admin_ratings_path
    end

    # --- submit_login ---

    test "submit_login with valid token authenticates and redirects to ratings" do
      post admin_login_path, params: { token: "test-token" }
      assert_redirected_to admin_ratings_path
      assert_equal "Logged in successfully.", flash[:notice]
    end

    test "submit_login with invalid token redirects back with alert" do
      post admin_login_path, params: { token: "wrong-token" }
      assert_redirected_to admin_login_path
      assert_equal "Invalid token.", flash[:alert]
    end

    test "submit_login with missing token redirects back with alert" do
      post admin_login_path, params: {}
      assert_redirected_to admin_login_path
      assert_equal "Invalid token.", flash[:alert]
    end

    # --- logout ---

    test "logout clears session and redirects to login" do
      login_as_admin
      delete admin_logout_path
      assert_redirected_to admin_login_path

      # Confirm the session was actually cleared by hitting a protected page.
      get admin_ratings_path
      assert_redirected_to admin_login_path
    end

    # --- index (protected) ---

    test "index redirects unauthenticated visitors to login" do
      get admin_ratings_path
      assert_redirected_to admin_login_path
    end

    test "index renders successfully for authenticated admin" do
      login_as_admin
      get admin_ratings_path
      assert_response :success
    end

    test "index accepts sort, direction, and star-range filter params" do
      login_as_admin
      get admin_ratings_path, params: {
        sort: "total_count", direction: "desc", min_stars: 3, max_stars: 5
      }
      assert_response :success
    end

    private

    def login_as_admin
      post admin_login_path, params: { token: "test-token" }
    end
  end
end
