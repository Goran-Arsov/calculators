class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.string :filename, null: false
      t.string :title
      t.integer :byte_size, null: false

      t.timestamps
    end

    add_index :notes, :filename, unique: true
    add_index :notes, :created_at
  end
end
