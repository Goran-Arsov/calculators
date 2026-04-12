import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name1", "name2", "resultPercent", "resultLabel", "resultBar"]

  connect() { this.calculate() }

  calculate() {
    const name1 = (this.name1Target.value || "").trim()
    const name2 = (this.name2Target.value || "").trim()

    if (!name1 || !name2) { this.clear(); return }

    const sum1 = this.letterSum(name1)
    const sum2 = this.letterSum(name2)
    if (sum1 === 0 || sum2 === 0) { this.clear(); return }

    const total = sum1 + sum2
    const percent = 40 + ((total * 13) % 60)

    this.resultPercentTarget.textContent = `${percent}%`
    this.resultLabelTarget.textContent = this.label(percent)
    if (this.hasResultBarTarget) this.resultBarTarget.style.width = `${percent}%`
  }

  letterSum(str) {
    return str.toLowerCase().replace(/[^a-z]/g, "").split("").reduce((acc, c) => acc + (c.charCodeAt(0) - 96), 0)
  }

  label(percent) {
    if (percent >= 90) return "Soulmates"
    if (percent >= 75) return "Excellent match"
    if (percent >= 60) return "Good match"
    if (percent >= 50) return "Could work"
    return "Needs effort"
  }

  clear() {
    this.resultPercentTarget.textContent = "—"
    this.resultLabelTarget.textContent = "—"
    if (this.hasResultBarTarget) this.resultBarTarget.style.width = "0%"
  }

  copy() {
    navigator.clipboard.writeText(`Love compatibility: ${this.resultPercentTarget.textContent} — ${this.resultLabelTarget.textContent}`)
  }
}
