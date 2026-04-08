import { Controller } from "@hotwired/stimulus"

// Shows an "Install App" prompt when the browser supports PWA installation.
// Usage: <div data-controller="pwa-install" class="hidden">
export default class extends Controller {
  static targets = ["banner"]

  connect() {
    if (localStorage.getItem("calcwise_pwa_dismissed")) return

    this.handleBeforeInstall = (e) => {
      e.preventDefault()
      this.deferredPrompt = e
      this.element.classList.remove("hidden")
    }
    window.addEventListener("beforeinstallprompt", this.handleBeforeInstall)
  }

  disconnect() {
    if (this.handleBeforeInstall) {
      window.removeEventListener("beforeinstallprompt", this.handleBeforeInstall)
    }
  }

  install() {
    if (!this.deferredPrompt) return
    this.deferredPrompt.prompt()
    this.deferredPrompt.userChoice.then(() => {
      this.deferredPrompt = null
      this.element.classList.add("hidden")
    })
  }

  dismiss() {
    this.element.classList.add("hidden")
    localStorage.setItem("calcwise_pwa_dismissed", "true")
  }
}
