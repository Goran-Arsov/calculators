import { Controller } from "@hotwired/stimulus"

// Formats numeric inputs with thousand separators as the user types.
// Usage: <input data-controller="currency-input" data-action="input->currency-input#format">
export default class extends Controller {
  format(event) {
    const input = event.target
    const raw = input.value.replace(/,/g, "")
    if (raw === "" || raw === "-" || raw === ".") return
    const num = parseFloat(raw)
    if (isNaN(num)) return

    const cursorPos = input.selectionStart
    const oldLength = input.value.length

    // Format with commas
    const parts = raw.split(".")
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    input.value = parts.join(".")

    // Restore cursor position
    const newLength = input.value.length
    input.setSelectionRange(cursorPos + (newLength - oldLength), cursorPos + (newLength - oldLength))
  }

  // Get raw numeric value (strips commas)
  get rawValue() {
    return parseFloat(this.element.value.replace(/,/g, "")) || 0
  }
}
