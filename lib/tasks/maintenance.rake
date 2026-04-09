namespace :maintenance do
  desc "Remove calculator ratings older than 6 months"
  task purge_old_ratings: :environment do
    cutoff = 6.months.ago
    count = CalculatorRating.where("created_at < ?", cutoff).delete_all
    puts "Purged #{count} ratings older than #{cutoff.to_date}"
  end

  desc "Generate a new ADMIN_TOKEN and print update instructions"
  task rotate_admin_token: :environment do
    new_token = SecureRandom.hex(32)
    puts "New ADMIN_TOKEN: #{new_token}"
    puts ""
    puts "To apply:"
    puts "  1. Update ADMIN_TOKEN in your .env / .env.production file"
    puts "  2. Restart the Rails server to pick up the new value"
    puts "  3. All existing admin sessions will remain valid until they expire"
    puts "     (clear the session store if immediate invalidation is needed)"
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
