module AdHelper
  # Set these after AdSense approval
  ADSENSE_PUB_ID = ENV.fetch("ADSENSE_PUB_ID", "ca-pub-XXXXXXXXXXXXXXXX")
  ADSENSE_ENABLED = ENV.fetch("ADSENSE_ENABLED", "false") == "true"

  # Ad provider: "adsense" (default) or "gam" (Google Ad Manager / header bidding)
  AD_PROVIDER = ENV.fetch("AD_PROVIDER", "adsense").freeze

  # Auto Ads: when true, includes ?client= in the adsbygoogle.js script URL,
  # enabling Google to automatically place additional ads on the page.
  # Controlled separately from manual ad units. Requires dashboard opt-in too.
  AUTO_ADS_ENABLED = ENV.fetch("AUTO_ADS_ENABLED", "true") == "true"

  # Slot IDs — replace after creating ad units in AdSense dashboard
  AD_SLOTS = {
    "leaderboard"  => ENV.fetch("AD_SLOT_LEADERBOARD", ""),
    "in_results"   => ENV.fetch("AD_SLOT_IN_RESULTS", ""),
    "in_content"   => ENV.fetch("AD_SLOT_IN_CONTENT", ""),
    "sidebar"      => ENV.fetch("AD_SLOT_SIDEBAR", ""),
    "anchor"       => ENV.fetch("AD_SLOT_ANCHOR", ""),
    "multiplex"    => ENV.fetch("AD_SLOT_MULTIPLEX", "")
  }.freeze

  def adsense_enabled?
    ADSENSE_ENABLED && ADSENSE_PUB_ID != "ca-pub-XXXXXXXXXXXXXXXX"
  end

  def ad_provider
    AD_PROVIDER
  end

  def ad_provider_gam?
    AD_PROVIDER == "gam"
  end

  def adsense_pub_id
    ADSENSE_PUB_ID
  end

  def ad_slot_id(position)
    AD_SLOTS[position.to_s] || ""
  end

  def auto_ads_enabled?
    AUTO_ADS_ENABLED
  end

  def adsense_script_url
    base = "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"
    auto_ads_enabled? ? "#{base}?client=#{adsense_pub_id}" : base
  end

  def ad_slot(position)
    render "shared/ad_slot", slot: position
  end
end
