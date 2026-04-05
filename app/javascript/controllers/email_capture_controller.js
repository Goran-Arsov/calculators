import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner", "input"]

  connect() {
    if (localStorage.getItem("calcwise_email_dismissed") || localStorage.getItem("calcwise_email_subscribed")) {
      return
    }
    // Show after 2 calculations in this session
    const count = parseInt(sessionStorage.getItem("calcwise_calc_count") || "0")
    if (count >= 2) {
      this.bannerTarget.classList.remove("hidden")
    }
    // Increment on connect (each calculator page visit)
    sessionStorage.setItem("calcwise_calc_count", (count + 1).toString())
  }

  subscribe() {
    const email = this.inputTarget.value.trim()
    if (!email || !email.includes("@")) {
      this.inputTarget.classList.add("ring-2", "ring-red-400")
      return
    }
    // In production, POST to a newsletter API endpoint
    localStorage.setItem("calcwise_email_subscribed", "true")
    this.bannerTarget.innerHTML = '<div class="text-center py-2"><p class="text-sm font-medium text-green-600 dark:text-green-400">Thanks for subscribing!</p></div>'
  }

  dismiss() {
    localStorage.setItem("calcwise_email_dismissed", "true")
    this.bannerTarget.classList.add("hidden")
  }
}
