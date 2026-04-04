import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "aForC", "bForC", "resultC",
    "bForA", "cForA", "resultA",
    "aForB", "cForB", "resultB"
  ]

  calcC() {
    const a = parseFloat(this.aForCTarget.value)
    const b = parseFloat(this.bForCTarget.value)
    if (a > 0 && b > 0) {
      const c = Math.sqrt(a * a + b * b)
      this.resultCTarget.textContent = this.fmt(c)
    } else {
      this.resultCTarget.textContent = "—"
    }
  }

  calcA() {
    const b = parseFloat(this.bForATarget.value)
    const c = parseFloat(this.cForATarget.value)
    if (b > 0 && c > 0 && c > b) {
      const a = Math.sqrt(c * c - b * b)
      this.resultATarget.textContent = this.fmt(a)
    } else {
      this.resultATarget.textContent = c <= b && c > 0 && b > 0 ? "c must be > b" : "—"
    }
  }

  calcB() {
    const a = parseFloat(this.aForBTarget.value)
    const c = parseFloat(this.cForBTarget.value)
    if (a > 0 && c > 0 && c > a) {
      const b = Math.sqrt(c * c - a * a)
      this.resultBTarget.textContent = this.fmt(b)
    } else {
      this.resultBTarget.textContent = c <= a && c > 0 && a > 0 ? "c must be > a" : "—"
    }
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
