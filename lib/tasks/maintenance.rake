namespace :maintenance do
  desc "Remove calculator ratings older than 6 months"
  task purge_old_ratings: :environment do
    cutoff = 6.months.ago
    count = CalculatorRating.where("created_at < ?", cutoff).delete_all
    puts "Purged #{count} ratings older than #{cutoff.to_date}"
  end

  desc "Database maintenance: vacuum and analyze"
  task optimize_db: :environment do
    connection = ActiveRecord::Base.connection
    tables = %w[calculator_ratings blog_posts]

    tables.each do |table|
      connection.execute("VACUUM ANALYZE #{connection.quote_table_name(table)}")
    end
    puts "Database optimized"
  end
end
