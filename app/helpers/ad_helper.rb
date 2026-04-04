module AdHelper
  # Set these after AdSense approval
  ADSENSE_PUB_ID = ENV.fetch("ADSENSE_PUB_ID", "ca-pub-XXXXXXXXXXXXXXXX")
  ADSENSE_ENABLED = ENV.fetch("ADSENSE_ENABLED", "false") == "true"

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
