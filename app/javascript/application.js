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

  // --- Shareable calculator URLs ---
  // Read URL params and pre-fill matching calculator inputs on page load.
  // Works by matching param names to Stimulus target attribute values.
  const params = new URLSearchParams(window.location.search)
  if (params.size > 0) {
    const calcEl = document.querySelector("[data-controller*='calculator']")
    if (calcEl) {
      const inputs = calcEl.querySelectorAll("input, select")
      inputs.forEach((input) => {
        for (const attr of input.attributes) {
          if (attr.name.endsWith("-target")) {
            const targetName = attr.value
            if (params.has(targetName)) {
              input.value = params.get(targetName)
              input.dispatchEvent(new Event("input", { bubbles: true }))
              input.dispatchEvent(new Event("change", { bubbles: true }))
            }
          }
        }
      })
    }
  }

  // --- Scroll-depth GA4 tracking ---
  if (typeof gtag === "function") {
    let scrollMarkers = { 25: false, 50: false, 75: false, 100: false }
    const onScroll = () => {
      const scrollTop = window.scrollY
      const docHeight = document.documentElement.scrollHeight - window.innerHeight
      if (docHeight <= 0) return
      const pct = Math.round((scrollTop / docHeight) * 100)

      for (const milestone of [25, 50, 75, 100]) {
        if (pct >= milestone && !scrollMarkers[milestone]) {
          scrollMarkers[milestone] = true
          gtag("event", "scroll_depth", {
            percent: milestone,
            page_path: window.location.pathname
          })
        }
      }
      // Clean up after 100% reached
      if (scrollMarkers[100]) {
        window.removeEventListener("scroll", onScroll)
      }
    }
    window.addEventListener("scroll", onScroll, { passive: true })
  }
})

// "Copied!" feedback for all copy buttons
document.addEventListener("click", (e) => {
  const btn = e.target.closest("button")
  if (!btn) return
  const action = btn.getAttribute("data-action") || ""
  if (!action.includes("#copy")) return

  // Wait a tick for the copy() method to run, then show feedback
  setTimeout(() => {
    // Skip if already showing feedback
    if (btn.dataset.copyFeedback) return
    btn.dataset.copyFeedback = "true"

    const msg = document.createElement("div")
    msg.textContent = "Copied!"
    msg.className = "text-xs text-emerald-600 dark:text-emerald-400 font-medium mt-1.5 text-center animate-fade-in-up"
    btn.insertAdjacentElement("afterend", msg)

    setTimeout(() => {
      msg.remove()
      delete btn.dataset.copyFeedback
    }, 3000)
  }, 50)
})

// Clear ad state before Turbo caches the page to prevent duplicates
document.addEventListener("turbo:before-cache", () => {
  document.querySelectorAll("ins.adsbygoogle").forEach((ad) => {
    while (ad.firstChild) ad.firstChild.remove()
    delete ad.dataset.adsbygoogleStatus
  })
})

// Turbo navigation loading indicator.
// Use turbo:visit (fires only on real navigations) rather than
// turbo:before-fetch-request, which also fires on hover prefetches and
// would leave the cursor stuck in a "progress" state on link-heavy pages.
document.addEventListener("turbo:visit", () => {
  document.body.setAttribute("aria-busy", "true")
})

document.addEventListener("turbo:load", () => {
  document.body.removeAttribute("aria-busy")
})
