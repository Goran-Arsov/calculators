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
    // lb per 1,000 sq ft → kg per 100 m². 1,000 sq ft = 92.903 m², so 1 lb/1,000 sq ft = 0.4882 kg/100 m².
    const rateMetric = rate * 0.4882

    this.resultRateTarget.textContent = `${rate.toFixed(2)} lb / 1,000 sq ft (${rateMetric.toFixed(2)} kg / 100 m²)`
    this.resultPoundsTarget.textContent = `${pounds.toFixed(2)} lb (${kilos.toFixed(2)} kg)`
    this.resultOuncesTarget.textContent = `${(pounds * 16).toFixed(1)} oz (${(kilos * 1000).toFixed(0)} g)`
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
