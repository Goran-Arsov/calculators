class AddNotNullToCalculatorRatingScore < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    CalculatorRating.where(score: nil, direction: "up").update_all(score: 4)
    CalculatorRating.where(score: nil, direction: "down").update_all(score: 2)

    safety_assured do
      change_column_null :calculator_ratings, :score, false
    end
  end

  def down
    safety_assured do
      change_column_null :calculator_ratings, :score, true
    end
  end
end
