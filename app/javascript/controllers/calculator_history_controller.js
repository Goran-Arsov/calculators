import { Controller } from "@hotwired/stimulus"

// Attach to any calculator's results section to track history.
// Usage: <div data-controller="calculator-history" data-calculator-history-key-value="mortgage">
export default class extends Controller {
  static values = { key: String, max: { type: Number, default: 10 } }
  static targets = ["list"]

  save(detail) {
    const history = this.#load()
    history.unshift({ ...detail, timestamp: Date.now() })
    localStorage.setItem(this.#storageKey, JSON.stringify(history.slice(0, this.maxValue)))
    this.#render()
  }

  clear() {
    localStorage.removeItem(this.#storageKey)
    this.#render()
  }

  connect() {
    this.#render()
  }

  #load() {
    try {
      return JSON.parse(localStorage.getItem(this.#storageKey) || "[]")
    } catch { return [] }
  }

  get #storageKey() {
    return `calcwise_history_${this.keyValue}`
  }

  #render() {
    if (!this.hasListTarget) return
    const history = this.#load()
    if (history.length === 0) {
      this.listTarget.innerHTML = '<p class="text-sm text-gray-400 dark:text-gray-500">No recent calculations.</p>'
      return
    }
    this.listTarget.innerHTML = history.map((entry, i) => {
      const date = new Date(entry.timestamp).toLocaleDateString()
      const summary = Object.entries(entry)
        .filter(([k]) => k !== "timestamp")
        .map(([k, v]) => `<span class="text-gray-500 dark:text-gray-400">${k.replace(/_/g, " ")}:</span> ${v}`)
        .join(" &middot; ")
      return `<div class="py-2 ${i > 0 ? 'border-t border-gray-100 dark:border-gray-800' : ''} text-sm">
        <span class="text-xs text-gray-400">${date}</span>
        <div class="mt-0.5">${summary}</div>
      </div>`
    }).join("")
  }
}
