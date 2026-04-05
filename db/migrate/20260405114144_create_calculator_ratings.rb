class CreateCalculatorRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :calculator_ratings do |t|
      t.string :calculator_slug, null: false
      t.string :direction, null: false
      t.string :ip_hash, null: false

      t.timestamps
    end

    add_index :calculator_ratings, :calculator_slug
    add_index :calculator_ratings, [:calculator_slug, :ip_hash], unique: true
  end
end
