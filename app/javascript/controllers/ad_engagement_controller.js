import { Controller } from "@hotwired/stimulus"

// Tracks calculator engagement and fires GA4 events for better ad targeting.
// Attach to any calculator's root element via data-controller="ad-engagement".
// Listens for input events as a proxy for calculator usage.
export default class extends Controller {
  connect() {
    this.interactionCount = 0
    this.engagementTracked = false
  }

  // Call this from calculator input actions: data-action="input->ad-engagement#track"
  track() {
    this.interactionCount++

    // Fire GA4 engagement event after meaningful interaction (5+ inputs)
    if (this.interactionCount === 5 && !this.engagementTracked) {
      this.engagementTracked = true
      if (typeof gtag === "function") {
        gtag("event", "calculator_engaged", {
          page_path: window.location.pathname
        })
      }
    }
  }
}
