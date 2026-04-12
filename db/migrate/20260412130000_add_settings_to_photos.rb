class AddSettingsToPhotos < ActiveRecord::Migration[8.1]
  def change
    add_column :photos, :jpg_quality, :integer
    add_column :photos, :max_dimension, :integer
  end
end
