import { Controller } from "@hotwired/stimulus"

export default class CalculationHistoryController extends Controller {
  static targets = ["list", "empty", "container"]
  static values = { maxEntries: { type: Number, default: 20 } }

  connect() {
    this.render()
  }

  // Called by other controllers to save a calculation
  // Usage: this.dispatch("save", { detail: { calculator: "Mortgage", result: "$1,896/mo", url: "/finance/mortgage-calculator?..." } })
  static save(entry) {
    const history = CalculationHistoryController.load()
    history.unshift({
      ...entry,
      timestamp: new Date().toISOString()
    })
    // Keep only last 20 entries
    const trimmed = history.slice(0, 20)
    localStorage.setItem("calcwise_history", JSON.stringify(trimmed))
  }

  static load() {
    try {
      return JSON.parse(localStorage.getItem("calcwise_history") || "[]")
    } catch {
      return []
    }
  }

  render() {
    const history = CalculationHistoryController.load()

    if (history.length === 0) {
      if (this.hasEmptyTarget) this.emptyTarget.classList.remove("hidden")
      if (this.hasContainerTarget) this.containerTarget.classList.add("hidden")
      return
    }

    if (this.hasEmptyTarget) this.emptyTarget.classList.add("hidden")
    if (this.hasContainerTarget) this.containerTarget.classList.remove("hidden")

    if (!this.hasListTarget) return

    this.listTarget.innerHTML = history.map(entry => `
      <a href="${this.escapeHtml(entry.url || '#')}" class="flex items-center justify-between p-3 rounded-xl hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors group">
        <div>
          <div class="text-sm font-medium text-gray-900 dark:text-white group-hover:text-blue-600 dark:group-hover:text-blue-400">${this.escapeHtml(entry.calculator)}</div>
          <div class="text-xs text-gray-500 dark:text-gray-400">${this.escapeHtml(entry.result)}</div>
        </div>
        <time class="text-xs text-gray-400 dark:text-gray-500">${this.timeAgo(entry.timestamp)}</time>
      </a>
    `).join("")
  }

  clearHistory() {
    localStorage.removeItem("calcwise_history")
    this.render()
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str || ""
    return div.innerHTML
  }

  timeAgo(timestamp) {
    const seconds = Math.floor((Date.now() - new Date(timestamp).getTime()) / 1000)
    if (seconds < 60) return "just now"
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`
    return `${Math.floor(seconds / 86400)}d ago`
  }
}
