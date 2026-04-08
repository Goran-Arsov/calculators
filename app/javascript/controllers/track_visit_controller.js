import { Controller } from "@hotwired/stimulus"

// Automatically tracks calculator page visits in localStorage.
// Attach to a shared element on calculator pages (e.g. breadcrumbs).
// The slug is derived from the URL path (last segment).
//
// Usage: <nav data-controller="track-visit">
export default class extends Controller {
  static values = { maxEntries: { type: Number, default: 20 } }

  connect() {
    const slug = this.#slugFromPath()
    if (!slug) return

    this.#recordVisit(slug)
  }

  #slugFromPath() {
    const path = window.location.pathname.replace(/\/$/, "")
    const segments = path.split("/").filter(Boolean)
    // Only track pages with at least 2 segments (e.g. /finance/mortgage-calculator)
    if (segments.length < 2) return null
    return segments[segments.length - 1]
  }

  #recordVisit(slug) {
    const key = "calcwise_recent_visits"
    let visits = []

    try {
      visits = JSON.parse(localStorage.getItem(key) || "[]")
    } catch {
      visits = []
    }

    // Remove existing entry for this slug (dedup)
    visits = visits.filter(v => v.slug !== slug)

    // Add to front
    visits.unshift({ slug: slug, timestamp: Date.now() })

    // Cap at max entries
    visits = visits.slice(0, this.maxEntriesValue)

    localStorage.setItem(key, JSON.stringify(visits))
  }
}
