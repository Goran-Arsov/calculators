class CreateUserFormulas < ActiveRecord::Migration[8.1]
  def change
    create_table :user_formulas do |t|
      t.string :title
      t.text :description
      t.jsonb :formula_json
      t.string :category
      t.string :author_name
      t.string :author_email
      t.string :slug
      t.string :status, default: "pending"

      t.timestamps
    end

    add_index :user_formulas, :slug, unique: true
    add_index :user_formulas, :status
    add_index :user_formulas, :category
  end
end
