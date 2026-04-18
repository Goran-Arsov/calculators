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
end
