import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "reps", "epley", "brzycki", "average"]

  calculate() {
    const weight = parseFloat(this.weightTarget.value) || 0
    const reps = parseFloat(this.repsTarget.value) || 0

    if (weight <= 0 || reps <= 0) {
      this.clearResults()
      return
    }

    if (reps === 1) {
      this.epleyTarget.textContent = this.fmt(weight)
      this.brzyckiTarget.textContent = this.fmt(weight)
      this.averageTarget.textContent = this.fmt(weight)
      return
    }

    const epley = weight * (1 + reps / 30)
    const brzycki = weight * 36 / (37 - reps)
    const average = (epley + brzycki) / 2

    this.epleyTarget.textContent = this.fmt(epley)
    this.brzyckiTarget.textContent = this.fmt(brzycki)
    this.averageTarget.textContent = this.fmt(average)
  }

  clearResults() {
    this.epleyTarget.textContent = "—"
    this.brzyckiTarget.textContent = "—"
    this.averageTarget.textContent = "—"
  }

  copy() {
    const text = [
      `Epley 1RM: ${this.epleyTarget.textContent}`,
      `Brzycki 1RM: ${this.brzyckiTarget.textContent}`,
      `Average 1RM: ${this.averageTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return n.toFixed(1)
  }
}
