require "test_helper"

class ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  test "creates contact message and redirects" do
    assert_difference "ContactMessage.count", 1 do
      post contact_path, params: { contact_message: {
        name: "Jane Doe",
        email: "jane@example.com",
        subject: "general",
        message: "I love this calculator site!"
      } }
    end
    assert_redirected_to contact_path
    follow_redirect!
    assert_includes response.body, "Thank you"
  end

  test "redirects with alert on invalid submission" do
    assert_no_difference "ContactMessage.count" do
      post contact_path, params: { contact_message: {
        name: "",
        email: "bad",
        subject: "general",
        message: "Hi"
      } }
    end
    assert_redirected_to contact_path
  end
end
