class AddScoreToCalculatorRatings < ActiveRecord::Migration[8.1]
  def change
    add_column :calculator_ratings, :score, :integer
  end
end
