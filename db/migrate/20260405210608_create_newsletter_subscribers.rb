class CreateNewsletterSubscribers < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletter_subscribers do |t|
      t.string :email
      t.boolean :confirmed, default: false
      t.string :ip_address

      t.timestamps
    end
    add_index :newsletter_subscribers, :email, unique: true
  end
end
