import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "reps", "resultEpley", "resultBrzycki", "resultAverage"]

  calculate() {
    const weight = parseFloat(this.weightTarget.value) || 0
    const reps = parseFloat(this.repsTarget.value) || 0

    if (weight <= 0 || reps <= 0) {
      this.clearResults()
      return
    }

    if (reps === 1) {
      this.resultEpleyTarget.textContent = this.fmt(weight)
      this.resultBrzyckiTarget.textContent = this.fmt(weight)
      this.resultAverageTarget.textContent = this.fmt(weight)
      return
    }

    const epley = weight * (1 + reps / 30)
    const brzycki = weight * 36 / (37 - reps)
    const average = (epley + brzycki) / 2

    this.resultEpleyTarget.textContent = this.fmt(epley)
    this.resultBrzyckiTarget.textContent = this.fmt(brzycki)
    this.resultAverageTarget.textContent = this.fmt(average)
  }

  clearResults() {
    this.resultEpleyTarget.textContent = "0"
    this.resultBrzyckiTarget.textContent = "0"
    this.resultAverageTarget.textContent = "0"
  }

  fmt(n) {
    return n.toFixed(1)
  }
}
