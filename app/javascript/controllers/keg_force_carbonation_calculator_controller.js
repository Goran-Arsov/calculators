import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "tempF", "vols",
    "resultPsi", "resultKpa", "resultTempC", "resultStyle"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const tempF = parseFloat(this.tempFTarget.value) || 0
    const vols = parseFloat(this.volsTarget.value) || 0

    if (tempF < 28 || tempF > 80 || vols < 0.5 || vols > 5) {
      this.clearResults()
      return
    }

    let psi = -16.6999 -
              0.0101059 * tempF +
              0.00116512 * tempF * tempF +
              0.173354 * tempF * vols +
              4.24267 * vols -
              0.0684226 * vols * vols
    if (psi < 0) psi = 0
    const kpa = psi * 6.89476
    const tempC = (tempF - 32) * 5.0 / 9.0

    this.resultPsiTarget.textContent = psi.toFixed(1) + " PSI"
    this.resultKpaTarget.textContent = kpa.toFixed(1) + " kPa"
    this.resultTempCTarget.textContent = tempC.toFixed(1) + " °C"
    this.resultStyleTarget.textContent = this.style(vols)
  }

  style(v) {
    if (v < 1.5) return "British real ale"
    if (v < 2.0) return "English bitter, Irish stout"
    if (v < 2.5) return "American ales, porter, brown ale"
    if (v < 3.0) return "American lager, pilsner, IPA"
    if (v < 4.0) return "Belgian ales, wheat beer"
    return "Highly sparkling"
  }

  clearResults() {
    this.resultPsiTarget.textContent = "—"
    this.resultKpaTarget.textContent = "—"
    this.resultTempCTarget.textContent = "—"
    this.resultStyleTarget.textContent = "—"
  }

  copy() {
    const text = `Keg Force Carbonation:\nRegulator PSI: ${this.resultPsiTarget.textContent} (${this.resultKpaTarget.textContent})\nBeer Temp: ${this.resultTempCTarget.textContent}\nStyle: ${this.resultStyleTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
