module ProgrammaticSeo
  module Registry
    class << self
      def pages
        @pages ||= build_pages_index
      end

      def find(slug)
        pages[slug]
      end

      def valid_slug?(slug)
        pages.key?(slug)
      end

      def all_slugs
        pages.keys
      end

      def all_pages
        pages.values
      end

      def pages_for_category(category)
        pages.values.select { |p| p[:category] == category }
      end

      def pages_for_base(base_key)
        pages.values.select { |p| p[:base_key] == base_key }
      end

      def reset!
        @pages = nil
      end

      private

      def build_pages_index
        index = {}

        # Step 1: Load hand-written content files (high-quality, take precedence)
        hand_written_definitions.each do |defn|
          defn[:expansions].each do |expansion|
            slug = expansion[:slug]
            index[slug] = expansion.merge(
              base_key: defn[:base_key],
              category: defn[:category],
              stimulus_controller: defn[:stimulus_controller],
              form_partial: defn[:form_partial],
              icon_path: defn[:icon_path]
            )
          end
        end

        # Step 2: Auto-generate pages from Generator config (skip if hand-written exists)
        Generator::EXPANSIONS.each do |base_key, config|
          config[:patterns].each do |pattern_key|
            pattern = Generator::PATTERNS[pattern_key]
            next unless pattern

            page = ContentTemplates.build_page(base_key, config, pattern_key, pattern)
            slug = page[:slug]

            # Hand-written content takes precedence
            next if index.key?(slug)

            # Determine form partial: use extracted partial if it exists, otherwise nil (shows CTA)
            form_partial_path = Rails.root.join("app", "views", "programmatic", "forms", "_#{base_key.tr('-', '_')}.html.erb")
            form_partial = form_partial_path.exist? ? "programmatic/forms/#{base_key.tr('-', '_')}" : nil

            index[slug] = page.merge(
              base_key: base_key,
              category: config[:category],
              stimulus_controller: config[:controller],
              form_partial: form_partial,
              icon_path: find_icon_path(base_key, config[:category])
            )
          end
        end

        # Step 3: Fill in related_slugs for auto-generated pages that have empty arrays
        index.each do |slug, page|
          if page[:related_slugs].empty?
            siblings = index.values
              .select { |p| p[:base_key] == page[:base_key] && p[:slug] != slug }
              .first(3)
              .map { |p| p[:slug] }
            page[:related_slugs] = siblings
          end
        end

        index.freeze
      end

      def hand_written_definitions
        defs = []
        content_dir = Rails.root.join("lib", "programmatic_seo", "content")
        return defs unless content_dir.exist?

        Dir[content_dir.join("*.rb")].each do |file|
          # Module name from filename: fuel_cost.rb -> FuelCost
          module_name = File.basename(file, ".rb").split("_").map(&:capitalize).join
          begin
            defn = "ProgrammaticSeo::Content::#{module_name}::DEFINITION".constantize
            defs << defn if defn.is_a?(Hash)
          rescue NameError
            # Skip if module doesn't define DEFINITION
          end
        end
        defs
      end

      def find_icon_path(base_key, category)
        # Look up icon from calculator_helper arrays
        calc_slug = "#{base_key}-calculator"
        all_calcs = CalculatorHelper::ALL_CATEGORIES.values.flat_map { |c| c[:calculators] }
        match = all_calcs.find { |c| c[:slug] == calc_slug || c[:slug] == base_key }
        match&.dig(:icon_path) || "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"
      end
    end
  end
end
