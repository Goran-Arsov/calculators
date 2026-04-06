import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "count", "uppercase",
    "resultOutput", "resultVersion", "resultCount"
  ]

  generate() {
    const count = Math.min(10, Math.max(1, parseInt(this.countTarget.value) || 1))
    const uppercase = this.uppercaseTarget.checked

    const uuids = []
    for (let i = 0; i < count; i++) {
      let uuid = this.generateUUIDv4()
      if (uppercase) uuid = uuid.toUpperCase()
      uuids.push(uuid)
    }

    this.resultOutputTarget.value = uuids.join("\n")
    this.resultVersionTarget.textContent = "v4 (random)"
    this.resultCountTarget.textContent = count
  }

  generateUUIDv4() {
    // Generate UUID v4 using crypto.getRandomValues for security
    const bytes = new Uint8Array(16)
    crypto.getRandomValues(bytes)

    // Set version bits (0100 for v4)
    bytes[6] = (bytes[6] & 0x0f) | 0x40
    // Set variant bits (10xx for RFC 4122)
    bytes[8] = (bytes[8] & 0x3f) | 0x80

    const hex = Array.from(bytes, b => b.toString(16).padStart(2, "0")).join("")

    return [
      hex.slice(0, 8),
      hex.slice(8, 12),
      hex.slice(12, 16),
      hex.slice(16, 20),
      hex.slice(20, 32)
    ].join("-")
  }

  copy() {
    const text = this.resultOutputTarget.value
    if (!text) return

    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }
}
