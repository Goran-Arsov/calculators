import { Controller } from "@hotwired/stimulus"

const MILESTONES = [
  { label: "First kiss", days: 14 },
  { label: "Said 'I love you'", days: 120 },
  { label: "Met the parents", days: 150 },
  { label: "First vacation together", days: 240 },
  { label: "Moved in together", days: 525 },
  { label: "Got a pet together", days: 700 },
  { label: "Engagement", days: 900 },
  { label: "Marriage", days: 1365 },
  { label: "First child", days: 1820 }
]

export default class extends Controller {
  static targets = ["start", "resultList", "resultNext"]

  connect() { this.calculate() }

  calculate() {
    if (!this.startTarget.value) { this.clear(); return }
    const start = new Date(this.startTarget.value)
    const now = new Date()
    if (isNaN(start.getTime()) || start > now) { this.clear(); return }

    const totalDays = Math.floor((now - start) / 86400000)

    this.resultListTarget.innerHTML = MILESTONES.map(ms => {
      const passed = totalDays >= ms.days
      const icon = passed ? "✓" : "○"
      const status = passed ? "passed" : `in ${ms.days - totalDays} days`
      return `<li class="flex justify-between items-center"><span>${icon} ${ms.label}</span><span class="text-xs ${passed ? 'text-pink-700 dark:text-pink-300' : 'text-gray-500'}">${status}</span></li>`
    }).join("")

    const next = MILESTONES.find(ms => totalDays < ms.days)
    this.resultNextTarget.textContent = next ? `${next.label} in ${next.days - totalDays} days` : "All major milestones passed!"
  }

  clear() {
    this.resultListTarget.innerHTML = ""
    this.resultNextTarget.textContent = "—"
  }

  copy() {
    navigator.clipboard.writeText(`Next milestone: ${this.resultNextTarget.textContent}`)
  }
}
