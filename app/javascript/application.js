// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Re-initialize AdSense ad slots after Turbo navigations
document.addEventListener("turbo:load", () => {
  if (typeof window.adsbygoogle !== "undefined") {
    document.querySelectorAll("ins.adsbygoogle[data-ad-slot]").forEach((ad) => {
      if (!ad.dataset.adsbygoogleStatus) {
        try { (adsbygoogle = window.adsbygoogle || []).push({}) } catch (e) {}
      }
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
