import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "force", "displacement",
    "resultKHooke", "resultPEHooke",
    "mass", "period",
    "resultKOsc", "resultFreqOsc", "resultAngularFreqOsc",
    "hookesResults", "oscResults"
  ]

  calcHooke() {
    const f = parseFloat(this.forceTarget.value)
    const x = parseFloat(this.displacementTarget.value)

    if (isNaN(f) || f === 0 || isNaN(x) || x === 0) {
      this.hookesResultsTarget.classList.add("hidden")
      return
    }

    const k = Math.abs(f) / Math.abs(x)
    const pe = 0.5 * k * x * x

    this.hookesResultsTarget.classList.remove("hidden")
    this.resultKHookeTarget.textContent = this.fmt(k) + " N/m"
    this.resultPEHookeTarget.textContent = this.fmt(pe) + " J"
  }

  calcOscillation() {
    const m = parseFloat(this.massTarget.value)
    const t = parseFloat(this.periodTarget.value)

    if (isNaN(m) || m <= 0 || isNaN(t) || t <= 0) {
      this.oscResultsTarget.classList.add("hidden")
      return
    }

    const k = Math.pow(2 * Math.PI / t, 2) * m
    const freq = 1 / t
    const omega = 2 * Math.PI * freq

    this.oscResultsTarget.classList.remove("hidden")
    this.resultKOscTarget.textContent = this.fmt(k) + " N/m"
    this.resultFreqOscTarget.textContent = this.fmt(freq) + " Hz"
    this.resultAngularFreqOscTarget.textContent = this.fmt(omega) + " rad/s"
  }

  fmt(n) {
    const abs = Math.abs(n)
    if (abs >= 1e6) return n.toExponential(4)
    if (abs >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const results = card.querySelectorAll("[data-result]")
    const lines = Array.from(results).map(el => el.textContent)
    navigator.clipboard.writeText(card.dataset.card + ": " + lines.join(" | "))
  }
}
