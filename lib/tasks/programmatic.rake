namespace :programmatic do
  desc "List all programmatic pages with their slugs and categories"
  task list: :environment do
    ProgrammaticSeo::Registry.all_pages.each do |page|
      puts "#{page[:category].ljust(15)} #{page[:slug]}"
    end
    puts "\nTotal: #{ProgrammaticSeo::Registry.all_slugs.count} pages"
  end

  desc "Validate all programmatic page definitions"
  task validate: :environment do
    required_keys = %i[slug route_name title h1 meta_description intro how_it_works example tips faq category stimulus_controller]
    errors = []

    ProgrammaticSeo::Registry.all_pages.each do |page|
      slug = page[:slug]

      # Check required keys
      missing = required_keys.select { |k| page[k].blank? }
      errors << "#{slug}: missing #{missing.join(', ')}" if missing.any?

      # Check FAQ count
      if page[:faq].present? && page[:faq].length < 3
        errors << "#{slug}: needs at least 3 FAQ entries (has #{page[:faq].length})"
      end

      # Check word count
      word_count = [
        page[:intro],
        page.dig(:how_it_works, :paragraphs)&.join(" "),
        page.dig(:example, :scenario),
        page.dig(:example, :steps)&.join(" "),
        page[:tips]&.join(" "),
        page[:faq]&.map { |f| f[:answer] }&.join(" ")
      ].compact.join(" ").split.size

      if word_count < 400
        errors << "#{slug}: only #{word_count} words of content (minimum 400)"
      end

      # Check related_slugs reference real pages
      (page[:related_slugs] || []).each do |related|
        unless ProgrammaticSeo::Registry.valid_slug?(related)
          errors << "#{slug}: references non-existent related slug '#{related}'"
        end
      end

      # Check title length
      if page[:title].present? && page[:title].length > 70
        errors << "#{slug}: title too long (#{page[:title].length} chars, max 70)"
      end

      # Check meta description length
      if page[:meta_description].present? && page[:meta_description].length > 160
        errors << "#{slug}: meta_description too long (#{page[:meta_description].length} chars, max 160)"
      end
    end

    if errors.empty?
      puts "All #{ProgrammaticSeo::Registry.all_slugs.count} pages are valid."
    else
      errors.each { |e| puts "ERROR: #{e}" }
      puts "\n#{errors.count} errors found."
      exit 1
    end
  end

  desc "Check for slug collisions with existing routes"
  task check_collisions: :environment do
    collisions = []
    all_categories = CalculatorRegistry::ALL_CATEGORIES rescue {}

    ProgrammaticSeo::Registry.all_slugs.each do |slug|
      all_categories.each_value do |category|
        (category[:calculators] || []).each do |calc|
          if calc[:slug] == slug
            collisions << "#{slug} collides with existing calculator #{calc[:name]}"
          end
        end
      end
    end

    if collisions.empty?
      puts "No collisions found among #{ProgrammaticSeo::Registry.all_slugs.count} programmatic slugs."
    else
      collisions.each { |c| puts "COLLISION: #{c}" }
      puts "\n#{collisions.count} collisions found."
      exit 1
    end
  end
end
