class CreateContactMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_messages do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.text :message
      t.string :ip_address
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
