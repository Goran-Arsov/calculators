# frozen_string_literal: true

module Localization
  # Single source of truth for which calculator pages have localized versions
  # under /:locale/... URLs.
  #
  # Used by:
  # - SeoHelper#hreflang_tags (emits <link rel="alternate"> only for these pages)
  # - SitemapController#locale (generates per-locale sitemaps)
  # - Language switcher UI
  #
  # MUST stay in sync with the `scope "/:locale"` block in config/routes.rb.
  # The invariant is verified by test/lib/localization/translatable_registry_test.rb,
  # which walks the actual route table and asserts agreement. If that test
  # fails, update ENTRIES below to match the routes (or vice versa).
  module TranslatableRegistry
    SUPPORTED_LOCALES = %w[de fr es pt mk].freeze

    LOCALE_NAMES = {
      "de" => "Deutsch",
      "fr" => "Français",
      "es" => "Español",
      "pt" => "Português",
      "mk" => "Македонски"
    }.freeze

    # Shape: { controller_path => { action_name => slug } }
    # - controller_path matches Rails' controller_path at request time
    # - action_name is the Rails action (snake_case)
    # - slug is the final URL segment under /:locale/:scope/
    ENTRIES = {
      "everyday/calculators" => {
        "base64_encoder"         => "base64-encoder-decoder",
        "url_encoder"            => "url-encoder-decoder",
        "html_formatter"         => "html-formatter-beautifier",
        "css_formatter"          => "css-formatter-beautifier",
        "js_formatter"           => "javascript-formatter-beautifier",
        "json_validator"         => "json-validator",
        "json_to_yaml"           => "json-to-yaml-converter",
        "curl_to_code"           => "curl-to-code-converter",
        "json_to_typescript"     => "json-to-typescript-generator",
        "html_to_jsx"            => "html-to-jsx-converter",
        "hex_ascii"              => "hex-ascii-converter",
        "http_status_reference"  => "http-status-code-reference",
        "robots_txt"             => "robots-txt-generator",
        "htaccess_generator"     => "htaccess-generator",
        "regex_explainer"        => "regex-explainer",
        "og_preview"             => "open-graph-preview",
        "svg_to_png"             => "svg-to-png-converter"
      }.freeze,
      "finance/calculators" => {
        "mortgage"                   => "mortgage-calculator",
        "compound_interest"          => "compound-interest-calculator",
        "loan"                       => "loan-calculator",
        "investment"                 => "investment-calculator",
        "retirement"                 => "retirement-calculator",
        "invoice_generator"          => "invoice-generator",
        "detailed_invoice_generator" => "detailed-invoice-generator"
      }.freeze,
      "health/calculators" => {
        "bmi"      => "bmi-calculator",
        "calorie"  => "calorie-calculator",
        "body_fat" => "body-fat-calculator",
        "tdee"     => "tdee-calculator",
        "macro"    => "macro-calculator"
      }.freeze
    }.freeze

    module_function

    # Does (controller_path, action) have localized versions?
    def translatable?(controller_path, action_name)
      return false if controller_path.nil? || action_name.nil?

      ENTRIES.dig(controller_path, action_name.to_s).present?
    end

    # Rails action names (snake_case) for a controller_path
    def actions_for(controller_path)
      ENTRIES[controller_path]&.keys || []
    end

    # Flat list: [{ controller_path:, scope:, action:, slug: }, ...]
    # scope is the first path segment (e.g. "everyday", "finance", "health")
    def all_entries
      ENTRIES.flat_map do |controller_path, actions|
        scope = controller_path.split("/").first
        actions.map do |action, slug|
          { controller_path: controller_path, scope: scope, action: action, slug: slug }
        end
      end
    end
  end
end
