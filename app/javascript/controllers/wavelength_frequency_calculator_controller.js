import { Controller } from "@hotwired/stimulus"

const C = 299792458 // speed of light m/s
const H = 6.62607015e-34 // Planck constant J·s

export default class extends Controller {
  static targets = [
    "wavelengthIn", "resultFreqFromWl", "resultPeriodFromWl", "resultEnergyFromWl",
    "frequencyIn", "resultWlFromFreq", "resultPeriodFromFreq", "resultEnergyFromFreq",
    "energyIn", "resultWlFromE", "resultFreqFromE", "resultPeriodFromE"
  ]

  calcFromWavelength() {
    const wl = parseFloat(this.wavelengthInTarget.value)
    if (wl > 0) {
      const f = C / wl
      this.resultFreqFromWlTarget.textContent = this.fmtSci(f) + " Hz"
      this.resultPeriodFromWlTarget.textContent = this.fmtSci(1 / f) + " s"
      this.resultEnergyFromWlTarget.textContent = this.fmtSci(H * f) + " J"
    } else { this.clearCard("FromWl") }
  }

  calcFromFrequency() {
    const f = parseFloat(this.frequencyInTarget.value)
    if (f > 0) {
      const wl = C / f
      this.resultWlFromFreqTarget.textContent = this.fmtSci(wl) + " m"
      this.resultPeriodFromFreqTarget.textContent = this.fmtSci(1 / f) + " s"
      this.resultEnergyFromFreqTarget.textContent = this.fmtSci(H * f) + " J"
    } else { this.clearCard("FromFreq") }
  }

  calcFromEnergy() {
    const e = parseFloat(this.energyInTarget.value)
    if (e > 0) {
      const f = e / H
      const wl = C / f
      this.resultWlFromETarget.textContent = this.fmtSci(wl) + " m"
      this.resultFreqFromETarget.textContent = this.fmtSci(f) + " Hz"
      this.resultPeriodFromETarget.textContent = this.fmtSci(1 / f) + " s"
    } else { this.clearCard("FromE") }
  }

  clearCard(suffix) {
    this.element.querySelectorAll(`[data-wavelength-frequency-calculator-target*="${suffix}"]`).forEach(el => {
      if (el.dataset.result !== undefined) el.textContent = "—"
    })
  }

  fmtSci(n) {
    if (n === 0) return "0"
    if (Math.abs(n) >= 0.01 && Math.abs(n) < 1e6) return n.toFixed(4).replace(/\.?0+$/, "")
    return n.toExponential(4)
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const results = card.querySelectorAll("[data-result]")
    const text = Array.from(results).map(r => r.textContent).join(", ")
    navigator.clipboard.writeText(text)
  }
}
