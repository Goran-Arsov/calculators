import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["area", "nRate", "nPercent", "resultN", "resultPounds", "resultOunces", "resultKilos"]

  connect() { this.calculate() }

  calculate() {
    const area = parseFloat(this.areaTarget.value)
    const nRate = parseFloat(this.nRateTarget.value)
    const nPct = parseFloat(this.nPercentTarget.value)

    if (!Number.isFinite(area) || area <= 0 ||
        !Number.isFinite(nRate) || nRate <= 0 ||
        !Number.isFinite(nPct) || nPct <= 0 || nPct > 100) {
      this.clear()
      return
    }

    const poundsOfN = (area / 1000) * nRate
    const poundsFert = poundsOfN / (nPct / 100)
    const kilos = poundsFert * 0.453592

    const kilosOfN = poundsOfN * 0.453592
    this.resultNTarget.textContent = `${poundsOfN.toFixed(2)} lb (${kilosOfN.toFixed(2)} kg)`
    this.resultPoundsTarget.textContent = `${poundsFert.toFixed(2)} lb (${kilos.toFixed(2)} kg)`
    this.resultOuncesTarget.textContent = `${(poundsFert * 16).toFixed(1)} oz (${(kilos * 1000).toFixed(0)} g)`
    this.resultKilosTarget.textContent = `${kilos.toFixed(2)} kg`
  }

  clear() {
    this.resultNTarget.textContent = "—"
    this.resultPoundsTarget.textContent = "—"
    this.resultOuncesTarget.textContent = "—"
    this.resultKilosTarget.textContent = "—"
  }

  copy() {
    const text = `Fertilizer needed:\nActual nitrogen: ${this.resultNTarget.textContent}\nFertilizer: ${this.resultPoundsTarget.textContent} (${this.resultKilosTarget.textContent})`
    navigator.clipboard.writeText(text)
  }
}
