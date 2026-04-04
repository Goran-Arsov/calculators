import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["a", "b", "resultGcd", "resultLcm"]

  calculate() {
    const a = parseInt(this.aTarget.value)
    const b = parseInt(this.bTarget.value)

    if (isNaN(a) || isNaN(b) || a === 0 || b === 0) {
      this.resultGcdTarget.textContent = "—"
      this.resultLcmTarget.textContent = "—"
      return
    }

    const absA = Math.abs(a)
    const absB = Math.abs(b)
    const gcdVal = this.gcd(absA, absB)
    const lcmVal = (absA * absB) / gcdVal

    this.resultGcdTarget.textContent = this.fmt(gcdVal)
    this.resultLcmTarget.textContent = this.fmt(lcmVal)
  }

  gcd(a, b) {
    while (b) {
      [a, b] = [b, a % b]
    }
    return a
  }

  fmt(n) {
    if (n >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const label = card.dataset.card
    const result = card.querySelector("[data-result]")
    navigator.clipboard.writeText(`${label}: ${result.textContent}`)
  }
}
