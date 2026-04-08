module AbTestHelper
  # Simple cookie-based A/B test infrastructure.
  # Assigns users to variants persistently and tracks in GA4.
  #
  # Usage in views:
  #   <% if ab_variant("sidebar_ads") == "b" %>
  #     <%# Show alternative ad layout %>
  #   <% end %>
  #
  # Usage in controllers:
  #   if ab_variant("sidebar_ads") == "b"
  #     # different logic
  #   end

  # Returns "a" or "b" for the given experiment, consistent per user.
  def ab_variant(experiment_name)
    cookie_key = "ab_#{experiment_name}"
    variant = cookies[cookie_key]

    unless %w[a b].include?(variant)
      variant = rand < 0.5 ? "a" : "b"
      cookies[cookie_key] = { value: variant, expires: 90.days.from_now, same_site: :lax }
    end

    variant
  end

  # Returns true if user is in variant "b" (the test group)
  def ab_test?(experiment_name)
    ab_variant(experiment_name) == "b"
  end

  # Renders a GA4 script tag to track the user's variant assignment.
  # Call once per page, e.g., in the layout or calculator view.
  def ab_tracking_tag(experiment_name)
    variant = ab_variant(experiment_name)
    safe_name = ERB::Util.json_escape(experiment_name.to_s)
    safe_variant = ERB::Util.json_escape(variant.to_s)
    tag.script("if(typeof gtag===\"function\"){gtag(\"event\",\"experiment_impression\",{experiment:\"#{safe_name}\",variant:\"#{safe_variant}\"})}".html_safe)
  end
end
