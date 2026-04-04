// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Re-initialize AdSense ad slots after Turbo navigations
document.addEventListener("turbo:load", () => {
  if (typeof window.adsbygoogle !== "undefined") {
    document.querySelectorAll("ins.adsbygoogle[data-ad-slot]").forEach((ad) => {
      if (!ad.dataset.adsbygoogleStatus) {
        const slot = ad.closest("[data-ad-slot]")
        const isAboveFold = slot && slot.dataset.adSlot === "leaderboard"

        if (isAboveFold) {
          try { (adsbygoogle = window.adsbygoogle || []).push({}) } catch (e) {}
        } else {
          // Use requestIdleCallback for non-above-fold ads to improve CWV
          if ("requestIdleCallback" in window) {
            requestIdleCallback(() => {
              try { (adsbygoogle = window.adsbygoogle || []).push({}) } catch (e) {}
            })
          } else {
            try { (adsbygoogle = window.adsbygoogle || []).push({}) } catch (e) {}
          }
        }
      }
    })
  }

  // Track ad impressions in GA4 for per-page RPM analysis
  if (typeof gtag === "function") {
    const adSlots = document.querySelectorAll("[data-ad-slot]")
    adSlots.forEach((slot) => {
      gtag("event", "ad_slot_loaded", {
        ad_slot: slot.dataset.adSlot,
        page_path: window.location.pathname
      })
    })
  }
})

// Clear ad state before Turbo caches the page to prevent duplicates
document.addEventListener("turbo:before-cache", () => {
  document.querySelectorAll("ins.adsbygoogle").forEach((ad) => {
    while (ad.firstChild) ad.firstChild.remove()
    delete ad.dataset.adsbygoogleStatus
  })
})
