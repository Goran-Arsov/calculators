module ProgrammaticSeo
  module Registry
    # Set PROGRAMMATIC_AUTO_PAGES=true to enable auto-generated pages beyond the hand-written ones.
    # Default: only hand-written content files are live (safe for AdSense).
    AUTO_PAGES_ENABLED = ENV.fetch("PROGRAMMATIC_AUTO_PAGES", "false") == "true"

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

      # Scores a page's content quality from 0–100.
      # Used to flag thin/low-quality auto-generated pages for noindex.
      def quality_score(page)
        score = 0

        # Word count: 0-30 points
        word_count = [
          page[:intro],
          page.dig(:how_it_works, :paragraphs)&.join(" "),
          page.dig(:example, :scenario),
          page.dig(:example, :steps)&.join(" "),
          page[:tips]&.join(" "),
          page[:faq]&.map { |f| f[:answer] }&.join(" ")
        ].compact.join(" ").split.size

        if word_count >= 800
          score += 30
        elsif word_count >= 600
          score += 25
        elsif word_count >= 400
          score += 15
        end

        # FAQ depth: 0-20 points
        faq_count = page[:faq]&.size || 0
        if faq_count >= 5
          score += 20
        elsif faq_count >= 3
          score += 10
        end

        # Has form_partial (embedded calculator): 0-20 points
        if page[:form_partial].present?
          score += 20
        else
          score += 5
        end

        # Has specific example with numeric steps: 0-15 points
        steps = page.dig(:example, :steps)
        if steps.is_a?(Array) && steps.any? { |s| s.match?(/\d/) }
          score += 15
        end

        # Has related_slugs: 0-15 points
        related = page[:related_slugs]
        if related.is_a?(Array)
          if related.size >= 3
            score += 15
          elsif related.size >= 1
            score += 10
          end
        end

        score
      end

      # Minimum content-quality score (0–100) required before an auto-generated
      # programmatic page is added to the sitemap and rendered without noindex.
      # Raised from 60 to 75 to keep templated pages out of Google's index;
      # 75 effectively requires ≥600 words, ≥3 FAQs, an embedded form, a
      # numeric example, and ≥1 related slug.
      INDEXABLE_QUALITY_THRESHOLD = 75

      # Returns true if the page meets the minimum quality threshold for indexing.
      def indexable?(page)
        quality_score(page) >= INDEXABLE_QUALITY_THRESHOLD
      end

      # Returns the lastmod date string for a programmatic page.
      # Hand-written pages use the content file's mtime; auto-generated pages use
      # the ContentTemplates file mtime. Falls back to beginning of month.
      def lastmod_for(slug)
        page = find(slug)
        return Date.current.to_s unless page

        # Hand-written content: find the source file by matching base_key across
        # all content definition files.
        if page[:base_key]
          content_dir = Rails.root.join("lib", "programmatic_seo", "content")
          if content_dir.exist?
            Dir[content_dir.join("*.rb")].each do |file|
              module_name = File.basename(file, ".rb").split("_").map(&:capitalize).join
              begin
                defn = "ProgrammaticSeo::Content::#{module_name}::DEFINITION".constantize
                if defn.is_a?(Hash) && defn[:base_key] == page[:base_key]
                  return File.mtime(file).to_date.to_s
                end
              rescue NameError
                next
              end
            end
          end
        end

        # Auto-generated pages: use the ContentTemplates file mtime
        template_file = Rails.root.join("lib", "programmatic_seo", "content_templates.rb")
        if template_file.exist?
          return File.mtime(template_file).to_date.to_s
        end

        Date.current.beginning_of_month.to_s
      end

      private

      def build_pages_index
        index = {}

        # Step 1: Load hand-written content files (always live — high-quality, AdSense-safe)
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

        # Step 2: Auto-generate pages from Generator config (only when enabled)
        if AUTO_PAGES_ENABLED
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

        # Step 4: Score each page's content quality and flag indexability
        index.each_value do |page|
          page[:quality_score] = quality_score(page)
          page[:indexable] = page[:quality_score] >= INDEXABLE_QUALITY_THRESHOLD
        end

        index.freeze
      end

      def hand_written_definitions
        defs = []
        content_dir = Rails.root.join("lib", "programmatic_seo", "content")
        return defs unless content_dir.exist?

        Dir[content_dir.join("*.rb")].each do |file|
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
        calc_slug = "#{base_key}-calculator"
        all_calcs = CalculatorRegistry::ALL_CATEGORIES.values.flat_map { |c| c[:calculators] }
        match = all_calcs.find { |c| c[:slug] == calc_slug || c[:slug] == base_key }
        match&.dig(:icon_path) || "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"
      end
    end
  end
end
