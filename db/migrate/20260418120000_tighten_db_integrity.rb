class TightenDbIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  NEW_EMAIL_INDEX = "index_newsletter_subscribers_on_lower_email".freeze
  OLD_EMAIL_INDEX = "index_newsletter_subscribers_on_email".freeze

  def up
    dup = NewsletterSubscriber
      .group("lower(email)")
      .having("count(*) > 1")
      .count
    if dup.any?
      raise "Aborting: case-duplicate emails in newsletter_subscribers: #{dup.keys.inspect}"
    end

    safety_assured do
      change_column_null :newsletter_subscribers, :email, false
      change_column_null :newsletter_subscribers, :confirmed, false, false

      change_column_null :contact_messages, :name, false
      change_column_null :contact_messages, :email, false
      change_column_null :contact_messages, :subject, false
      change_column_null :contact_messages, :message, false
      change_column_null :contact_messages, :read, false, false

      change_column_null :blog_posts, :title, false
      change_column_null :blog_posts, :slug, false
      change_column_null :blog_posts, :body, false
      change_column_null :blog_posts, :excerpt, false

      change_column_null :user_formulas, :title, false
      change_column_null :user_formulas, :description, false
      change_column_null :user_formulas, :formula_json, false
      change_column_null :user_formulas, :category, false
      change_column_null :user_formulas, :author_name, false
      change_column_null :user_formulas, :slug, false
    end

    unless index_name_exists?(:newsletter_subscribers, NEW_EMAIL_INDEX)
      add_index :newsletter_subscribers, "lower(email)",
                unique: true,
                name: NEW_EMAIL_INDEX,
                algorithm: :concurrently
    end

    if index_name_exists?(:newsletter_subscribers, OLD_EMAIL_INDEX)
      remove_index :newsletter_subscribers,
                   name: OLD_EMAIL_INDEX,
                   algorithm: :concurrently
    end
  end

  def down
    safety_assured do
      change_column_null :user_formulas, :slug, true
      change_column_null :user_formulas, :author_name, true
      change_column_null :user_formulas, :category, true
      change_column_null :user_formulas, :formula_json, true
      change_column_null :user_formulas, :description, true
      change_column_null :user_formulas, :title, true

      change_column_null :blog_posts, :excerpt, true
      change_column_null :blog_posts, :body, true
      change_column_null :blog_posts, :slug, true
      change_column_null :blog_posts, :title, true

      change_column_null :contact_messages, :read, true
      change_column_null :contact_messages, :message, true
      change_column_null :contact_messages, :subject, true
      change_column_null :contact_messages, :email, true
      change_column_null :contact_messages, :name, true

      change_column_null :newsletter_subscribers, :confirmed, true
      change_column_null :newsletter_subscribers, :email, true
    end

    unless index_name_exists?(:newsletter_subscribers, OLD_EMAIL_INDEX)
      add_index :newsletter_subscribers, :email,
                unique: true,
                name: OLD_EMAIL_INDEX,
                algorithm: :concurrently
    end

    if index_name_exists?(:newsletter_subscribers, NEW_EMAIL_INDEX)
      remove_index :newsletter_subscribers,
                   name: NEW_EMAIL_INDEX,
                   algorithm: :concurrently
    end
  end
end
