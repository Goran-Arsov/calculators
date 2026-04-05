require "test_helper"

class NewsletterSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "subscribes with valid email" do
    assert_difference "NewsletterSubscriber.count", 1 do
      post newsletter_subscribe_path, params: { newsletter_subscriber: { email: "new@example.com" } }
    end
    assert_redirected_to root_path
  end

  test "handles duplicate email gracefully" do
    NewsletterSubscriber.create!(email: "existing@example.com")
    assert_no_difference "NewsletterSubscriber.count" do
      post newsletter_subscribe_path, params: { newsletter_subscriber: { email: "existing@example.com" } }
    end
    assert_redirected_to root_path
  end

  test "json subscribe returns success" do
    post newsletter_subscribe_path, params: { newsletter_subscriber: { email: "json@example.com" } },
         headers: { "Accept" => "application/json" }
    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
  end

  test "json subscribe with invalid email returns error" do
    post newsletter_subscribe_path, params: { newsletter_subscriber: { email: "" } },
         headers: { "Accept" => "application/json" }
    assert_response :unprocessable_entity
  end
end
