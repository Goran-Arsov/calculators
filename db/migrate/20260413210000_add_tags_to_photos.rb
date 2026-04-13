class AddTagsToPhotos < ActiveRecord::Migration[8.1]
  def change
    add_column :photos, :tags, :string, array: true, default: []
    add_index :photos, :tags, using: "gin"
  end
end
