class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.string :filename, null: false
      t.string :original_filename
      t.integer :byte_size, null: false
      t.integer :width
      t.integer :height

      t.timestamps
    end

    add_index :photos, :filename, unique: true
    add_index :photos, :created_at
  end
end
