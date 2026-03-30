class CreateBlogPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.string :slug
      t.text :body
      t.string :excerpt
      t.string :meta_title
      t.string :meta_description
      t.datetime :published_at
      t.string :category

      t.timestamps
    end
    add_index :blog_posts, :slug, unique: true
  end
end
