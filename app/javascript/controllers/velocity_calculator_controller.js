import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "distanceForV", "timeForV", "resultVelocity",
    "velocityForD", "timeForD", "resultDistance",
    "distanceForT", "velocityForT", "resultTime"
  ]

  calcVelocity() {
    const d = parseFloat(this.distanceForVTarget.value)
    const t = parseFloat(this.timeForVTarget.value)
    this.resultVelocityTarget.textContent = (d > 0 && t > 0) ? this.fmt(d / t) + " m/s" : "—"
  }

  calcDistance() {
    const v = parseFloat(this.velocityForDTarget.value)
    const t = parseFloat(this.timeForDTarget.value)
    this.resultDistanceTarget.textContent = (v > 0 && t > 0) ? this.fmt(v * t) + " m" : "—"
  }

  calcTime() {
    const d = parseFloat(this.distanceForTTarget.value)
    const v = parseFloat(this.velocityForTTarget.value)
    this.resultTimeTarget.textContent = (d > 0 && v > 0) ? this.fmt(d / v) + " s" : "—"
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
