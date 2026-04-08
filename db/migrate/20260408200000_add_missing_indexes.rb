class AddMissingIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :contact_messages, [:read, :created_at], name: "index_contact_messages_on_read_and_created_at"
    add_index :contact_messages, :email, name: "index_contact_messages_on_email"
    add_index :newsletter_subscribers, :confirmed, name: "index_newsletter_subscribers_on_confirmed"
    add_index :blog_posts, :published_at, name: "index_blog_posts_on_published_at"
  end
end
