import { Controller } from "@hotwired/stimulus"

const STANDARD_BREAKERS = [15, 20, 25, 30, 40, 50, 60, 70, 80, 100, 125, 150, 175, 200]

export default class extends Controller {
  static targets = [
    "panelWatts", "panelCount", "ratio", "voltage",
    "resultArrayDc", "resultInverter", "resultAmps", "resultBreaker"
  ]

  connect() { this.calculate() }

  calculate() {
    const watts = parseFloat(this.panelWattsTarget.value) || 0
    const count = parseInt(this.panelCountTarget.value, 10) || 0
    const ratio = parseFloat(this.ratioTarget.value) || 1.2
    const voltage = parseFloat(this.voltageTarget.value) || 240

    if (watts <= 0 || count < 1 || ratio < 1.0 || ratio > 1.5 || voltage <= 0) {
      this.clear()
      return
    }

    const arrayDcW = watts * count
    const arrayDcKw = arrayDcW / 1000
    const inverterAcW = arrayDcW / ratio
    const inverterAcKw = inverterAcW / 1000
    const inverterAmps = inverterAcW / voltage
    const breakerRequired = inverterAmps * 1.25
    const recommendedBreaker = STANDARD_BREAKERS.find(b => b >= breakerRequired) || 200

    this.resultArrayDcTarget.textContent = `${arrayDcW.toLocaleString()} W DC (${arrayDcKw.toFixed(2)} kW)`
    this.resultInverterTarget.textContent = `${inverterAcW.toFixed(0)} W AC (${inverterAcKw.toFixed(2)} kW)`
    this.resultAmpsTarget.textContent = `${inverterAmps.toFixed(1)} A @ ${voltage} V`
    this.resultBreakerTarget.textContent = `${recommendedBreaker} A breaker (${breakerRequired.toFixed(1)} A required by NEC 690.8)`
  }

  clear() {
    ["ArrayDc","Inverter","Amps","Breaker"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Solar inverter sizing:",
      `Array DC: ${this.resultArrayDcTarget.textContent}`,
      `Inverter AC: ${this.resultInverterTarget.textContent}`,
      `Max amps: ${this.resultAmpsTarget.textContent}`,
      `Breaker: ${this.resultBreakerTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
