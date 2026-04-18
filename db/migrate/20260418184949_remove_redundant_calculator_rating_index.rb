class RemoveRedundantCalculatorRatingIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :calculator_ratings,
      column: :calculator_slug,
      name: "index_calculator_ratings_on_calculator_slug"
  end
end
