import { Controller } from "@hotwired/stimulus"

const RATES = {
  kentucky_bluegrass: 2.0,
  tall_fescue: 8.0,
  fine_fescue: 4.0,
  perennial_ryegrass: 8.0,
  bermudagrass: 1.5,
  zoysia: 2.0,
  centipede: 0.5,
  bahiagrass: 7.0
}

export default class extends Controller {
  static targets = ["area", "seedType", "purpose", "resultRate", "resultPounds", "resultOunces", "resultKilos"]

  connect() { this.calculate() }

  calculate() {
    const area = parseFloat(this.areaTarget.value)
    const seedType = this.seedTypeTarget.value
    const purpose = this.purposeTarget.value
    const base = RATES[seedType]

    if (!Number.isFinite(area) || area <= 0 || !base) {
      this.clear()
      return
    }

    const rate = purpose === "overseed" ? base / 2 : base
    const pounds = (area / 1000) * rate
    const kilos = pounds * 0.453592

    this.resultRateTarget.textContent = `${rate.toFixed(2)} lb / 1,000 sq ft`
    this.resultPoundsTarget.textContent = `${pounds.toFixed(2)} lb`
    this.resultOuncesTarget.textContent = `${(pounds * 16).toFixed(1)} oz`
    this.resultKilosTarget.textContent = `${kilos.toFixed(2)} kg`
  }

  clear() {
    this.resultRateTarget.textContent = "—"
    this.resultPoundsTarget.textContent = "—"
    this.resultOuncesTarget.textContent = "—"
    this.resultKilosTarget.textContent = "—"
  }

  copy() {
    const text = `Grass seed:\nRate: ${this.resultRateTarget.textContent}\nTotal: ${this.resultPoundsTarget.textContent} (${this.resultKilosTarget.textContent})`
    navigator.clipboard.writeText(text)
  }
}
