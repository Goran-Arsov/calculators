import { Controller } from "@hotwired/stimulus"

// Generates a shareable URL with pre-filled calculator input values.
// The recipient sees the exact same calculation when they open the link.
//
// Usage:
//   <div data-controller="share-results">
//     <button data-action="click->share-results#share">Share Results</button>
//     <div data-share-results-target="output" class="hidden">...</div>
//   </div>
export default class extends Controller {
  static targets = ["output", "url"]

  share() {
    const calcEl = document.querySelector("[data-controller*='calculator']")
    if (!calcEl) return

    const params = new URLSearchParams()
    let hasValues = false

    calcEl.querySelectorAll("input, select").forEach((input) => {
      if (!input.value) return
      for (const attr of input.attributes) {
        if (attr.name.endsWith("-target")) {
          params.set(attr.value, input.value)
          hasValues = true
        }
      }
    })

    if (!hasValues) return

    const shareUrl = `${window.location.origin}${window.location.pathname}?${params.toString()}`

    if (this.hasUrlTarget) {
      this.urlTarget.value = shareUrl
    }

    if (this.hasOutputTarget) {
      this.outputTarget.classList.remove("hidden")
    }

    navigator.clipboard.writeText(shareUrl).then(() => {
      this.element.querySelector("[data-share-feedback]")?.classList.remove("hidden")
      setTimeout(() => {
        this.element.querySelector("[data-share-feedback]")?.classList.add("hidden")
      }, 3000)
    })
  }
}
