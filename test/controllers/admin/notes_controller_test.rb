require "test_helper"

module Admin
  class NotesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @prev_token = ENV["ADMIN_TOKEN"]
      ENV["ADMIN_TOKEN"] = "test-token"
    end

    teardown do
      ENV["ADMIN_TOKEN"] = @prev_token
    end

    # --- Auth gate ---

    test "index redirects unauthenticated visitors to login" do
      get admin_notes_path
      assert_redirected_to admin_login_path
    end

    test "new redirects unauthenticated visitors to login" do
      get new_admin_note_path
      assert_redirected_to admin_login_path
    end

    test "create redirects unauthenticated visitors to login" do
      post admin_notes_path, params: { note: { title: "x", body: "y" } }
      assert_redirected_to admin_login_path
    end

    # --- Index ---

    test "index renders successfully for authenticated admin" do
      login_as_admin
      get admin_notes_path
      assert_response :success
    end

    test "index accepts a sort param from the whitelist" do
      login_as_admin
      get admin_notes_path, params: { sort: "name" }
      assert_response :success
    end

    test "index accepts a page param" do
      login_as_admin
      get admin_notes_path, params: { page: 1 }
      assert_response :success
    end

    # --- New ---

    test "new renders successfully for authenticated admin" do
      login_as_admin
      get new_admin_note_path
      assert_response :success
    end

    # --- Create ---

    test "create rejects empty body and redirects back with alert" do
      login_as_admin
      post admin_notes_path, params: { note: { title: "t", body: "" } }
      assert_redirected_to new_admin_note_path
      assert_equal "Please enter some text.", flash[:alert]
    end

    private

    def login_as_admin
      post admin_login_path, params: { token: "test-token" }
    end
  end
end
