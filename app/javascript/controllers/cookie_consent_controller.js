import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!localStorage.getItem("cookie_consent")) {
      this.element.classList.remove("hidden")
    }
  }

  accept() {
    localStorage.setItem("cookie_consent", "accepted")
    this.element.classList.add("hidden")
    // Consent Mode v2 — grant all signals
    if (typeof gtag === "function") {
      gtag("consent", "update", {
        "ad_storage": "granted",
        "ad_user_data": "granted",
        "ad_personalization": "granted",
        "analytics_storage": "granted"
      })
    }
  }

  reject() {
    localStorage.setItem("cookie_consent", "rejected")
    this.element.classList.add("hidden")
    // Consent stays denied — Google Consent Mode serves non-personalized
    // ads and uses conversion modeling for analytics uplift
  }
}
