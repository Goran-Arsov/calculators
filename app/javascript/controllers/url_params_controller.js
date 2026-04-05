import { Controller } from "@hotwired/stimulus"

// Reads URL query params and populates matching input targets on connect.
// Usage: <div data-controller="url-params" data-url-params-fields-value='["principal","rate","years"]'>
export default class extends Controller {
  static values = { fields: Array }

  connect() {
    const params = new URLSearchParams(window.location.search)
    if (params.size === 0) return

    let populated = false
    this.fieldsValue.forEach(field => {
      if (params.has(field)) {
        const input = this.element.querySelector(`[data-field="${field}"], [name="${field}"], input[placeholder][data-*-target*="${field}" i]`)
          || this.element.querySelector(`input[data-field="${field}"]`)
        if (input) {
          input.value = params.get(field)
          populated = true
        }
      }
    })

    if (populated) {
      // Trigger calculation after populating
      const firstInput = this.element.querySelector("input, select")
      if (firstInput) firstInput.dispatchEvent(new Event("input", { bubbles: true }))
    }
  }

  // Build a shareable URL with current input values
  buildShareUrl() {
    const url = new URL(window.location.href.split("?")[0])
    this.fieldsValue.forEach(field => {
      const input = this.element.querySelector(`[data-field="${field}"], [name="${field}"]`)
      if (input && input.value) url.searchParams.set(field, input.value)
    })
    return url.toString()
  }
}
