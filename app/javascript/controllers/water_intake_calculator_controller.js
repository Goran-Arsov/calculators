import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "exercise", "liters", "glasses", "ml"]

  calculate() {
    const weight = parseFloat(this.weightTarget.value) || 0
    const exercise = parseFloat(this.exerciseTarget.value) || 0

    if (weight <= 0) {
      this.clearResults()
      return
    }

    const baseLiters = weight * 0.033
    const extraLiters = (exercise / 30) * 0.5
    const totalLiters = baseLiters + extraLiters
    const totalMl = totalLiters * 1000
    const glasses = totalMl / 250

    this.litersTarget.textContent = `${this.fmt(totalLiters)} L`
    this.glassesTarget.textContent = Math.round(glasses)
    this.mlTarget.textContent = `${Math.round(totalMl).toLocaleString()} mL`
  }

  clearResults() {
    this.litersTarget.textContent = "— L"
    this.glassesTarget.textContent = "—"
    this.mlTarget.textContent = "— mL"
  }

  copy() {
    const text = [
      `Liters: ${this.litersTarget.textContent}`,
      `Glasses (250 mL): ${this.glassesTarget.textContent}`,
      `Milliliters: ${this.mlTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return n.toFixed(2)
  }
}
