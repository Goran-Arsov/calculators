module AdHelper
  # Set these after AdSense approval
  ADSENSE_PUB_ID = ENV.fetch("ADSENSE_PUB_ID", "ca-pub-XXXXXXXXXXXXXXXX")
  ADSENSE_ENABLED = ENV.fetch("ADSENSE_ENABLED", "false") == "true"

  # Ad provider: "adsense" (default) or "gam" (Google Ad Manager / header bidding)
  AD_PROVIDER = ENV.fetch("AD_PROVIDER", "adsense").freeze

  # Slot IDs — replace after creating ad units in AdSense dashboard
  AD_SLOTS = {
    "leaderboard"  => ENV.fetch("AD_SLOT_LEADERBOARD", ""),
    "in_results"   => ENV.fetch("AD_SLOT_IN_RESULTS", ""),
    "in_content"   => ENV.fetch("AD_SLOT_IN_CONTENT", ""),
    "sidebar"      => ENV.fetch("AD_SLOT_SIDEBAR", ""),
    "anchor"       => ENV.fetch("AD_SLOT_ANCHOR", ""),
    "multiplex"    => ENV.fetch("AD_SLOT_MULTIPLEX", ""),
    "after_intro"  => ENV.fetch("AD_SLOT_AFTER_INTRO", "")
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

  def ad_slot(position)
    render "shared/ad_slot", slot: position
  end
end
