import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "massForKE", "velForKE", "resultEnergy",
    "keForM", "velForM", "resultMass",
    "keForV", "massForV", "resultVelocity"
  ]

  calcEnergy() {
    const m = parseFloat(this.massForKETarget.value)
    const v = parseFloat(this.velForKETarget.value)
    this.resultEnergyTarget.textContent = (m > 0 && !isNaN(v)) ? this.fmt(0.5 * m * v * v) + " J" : "—"
  }

  calcMass() {
    const ke = parseFloat(this.keForMTarget.value)
    const v = parseFloat(this.velForMTarget.value)
    this.resultMassTarget.textContent = (ke >= 0 && !isNaN(ke) && v !== 0 && !isNaN(v)) ? this.fmt((2 * ke) / (v * v)) + " kg" : "—"
  }

  calcVelocity() {
    const ke = parseFloat(this.keForVTarget.value)
    const m = parseFloat(this.massForVTarget.value)
    this.resultVelocityTarget.textContent = (ke >= 0 && !isNaN(ke) && m > 0) ? this.fmt(Math.sqrt(2 * ke / m)) + " m/s" : "—"
  }

  fmt(n) {
    if (n >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const result = card.querySelector("[data-result]")
    navigator.clipboard.writeText(`${card.dataset.card}: ${result.textContent}`)
  }
}
