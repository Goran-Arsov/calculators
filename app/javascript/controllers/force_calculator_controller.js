import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "massForF", "accForF", "resultForce",
    "forceForM", "accForM", "resultMass",
    "forceForA", "massForA", "resultAcceleration"
  ]

  calcForce() {
    const m = parseFloat(this.massForFTarget.value)
    const a = parseFloat(this.accForFTarget.value)
    this.resultForceTarget.textContent = (m > 0 && !isNaN(a)) ? this.fmt(m * a) + " N" : "—"
  }

  calcMass() {
    const f = parseFloat(this.forceForMTarget.value)
    const a = parseFloat(this.accForMTarget.value)
    this.resultMassTarget.textContent = (!isNaN(f) && a !== 0 && !isNaN(a)) ? this.fmt(f / a) + " kg" : "—"
  }

  calcAcceleration() {
    const f = parseFloat(this.forceForATarget.value)
    const m = parseFloat(this.massForATarget.value)
    this.resultAccelerationTarget.textContent = (!isNaN(f) && m > 0) ? this.fmt(f / m) + " m/s²" : "—"
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const result = card.querySelector("[data-result]")
    navigator.clipboard.writeText(`${card.dataset.card}: ${result.textContent}`)
  }
}
