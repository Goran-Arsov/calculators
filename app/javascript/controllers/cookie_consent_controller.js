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
    // Enable personalized ads
    window.adsbygoogle = window.adsbygoogle || []
    if (typeof window.__tcfapi !== "undefined") {
      window.__tcfapi("postCustomConsent", 2, () => {}, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [], [])
    }
  }

  reject() {
    localStorage.setItem("cookie_consent", "rejected")
    this.element.classList.add("hidden")
    // Signal non-personalized ads only
    window.adsbygoogle = window.adsbygoogle || []
    window.adsbygoogle.requestNonPersonalizedAds = 1
  }
}
