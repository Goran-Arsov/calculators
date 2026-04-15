import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner", "input"]

  connect() {
    if (localStorage.getItem("calchammer_email_dismissed") || localStorage.getItem("calchammer_email_subscribed")) {
      return
    }
    // Show after 2 calculations in this session
    const count = parseInt(sessionStorage.getItem("calchammer_calc_count") || "0")
    if (count >= 2) {
      this.bannerTarget.classList.remove("hidden")
    }
    // Increment on connect (each calculator page visit)
    sessionStorage.setItem("calchammer_calc_count", (count + 1).toString())
  }

  subscribe() {
    const email = this.inputTarget.value.trim()
    if (!email || !email.includes("@")) {
      this.inputTarget.classList.add("ring-2", "ring-red-400")
      return
    }

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch("/newsletter", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": token, "Accept": "application/json" },
      body: JSON.stringify({ newsletter_subscriber: { email: email } })
    }).then(response => response.json()).then(() => {
      localStorage.setItem("calchammer_email_subscribed", "true")
      this.bannerTarget.innerHTML = '<div class="text-center py-2"><p class="text-sm font-medium text-green-600 dark:text-green-400">Thanks for subscribing!</p></div>'
    }).catch(() => {
      localStorage.setItem("calchammer_email_subscribed", "true")
      this.bannerTarget.innerHTML = '<div class="text-center py-2"><p class="text-sm font-medium text-green-600 dark:text-green-400">Thanks for subscribing!</p></div>'
    })
  }

  dismiss() {
    localStorage.setItem("calchammer_email_dismissed", "true")
    this.bannerTarget.classList.add("hidden")
  }
}
