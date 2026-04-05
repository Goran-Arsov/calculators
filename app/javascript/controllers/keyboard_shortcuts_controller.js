import { Controller } from "@hotwired/stimulus"

// Global keyboard shortcuts for calculator pages.
// Usage: <div data-controller="keyboard-shortcuts">
export default class extends Controller {
  static targets = ["results"]

  connect() {
    this.handleKeydown = this.#onKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  #onKeydown(event) {
    // Escape: clear all inputs
    if (event.key === "Escape" && !event.ctrlKey && !event.metaKey) {
      this.element.querySelectorAll("input[type='number'], input[type='text']").forEach(input => {
        input.value = ""
      })
      const firstInput = this.element.querySelector("input")
      if (firstInput) {
        firstInput.dispatchEvent(new Event("input", { bubbles: true }))
        firstInput.focus()
      }
    }

    // Ctrl/Cmd+Shift+C: copy results
    if ((event.ctrlKey || event.metaKey) && event.shiftKey && event.key === "C") {
      event.preventDefault()
      const copyBtn = this.element.querySelector("[data-action*='copy']")
      if (copyBtn) copyBtn.click()
    }
  }
}
