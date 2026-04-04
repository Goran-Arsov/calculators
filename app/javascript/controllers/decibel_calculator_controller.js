import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "powerRatio", "resultPowerDb",
    "powerDb", "resultPowerRatio",
    "voltageRatio", "resultVoltageDb",
    "voltageDb", "resultVoltageRatio"
  ]

  calcPowerDb() {
    const r = parseFloat(this.powerRatioTarget.value)
    this.resultPowerDbTarget.textContent = (r > 0) ? this.fmt(10 * Math.log10(r)) + " dB" : "—"
  }

  calcPowerRatio() {
    const db = parseFloat(this.powerDbTarget.value)
    this.resultPowerRatioTarget.textContent = !isNaN(db) ? this.fmt(Math.pow(10, db / 10)) + "×" : "—"
  }

  calcVoltageDb() {
    const r = parseFloat(this.voltageRatioTarget.value)
    this.resultVoltageDbTarget.textContent = (r > 0) ? this.fmt(20 * Math.log10(r)) + " dB" : "—"
  }

  calcVoltageRatio() {
    const db = parseFloat(this.voltageDbTarget.value)
    this.resultVoltageRatioTarget.textContent = !isNaN(db) ? this.fmt(Math.pow(10, db / 20)) + "×" : "—"
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
