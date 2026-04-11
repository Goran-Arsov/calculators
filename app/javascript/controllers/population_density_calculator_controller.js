import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "population", "area", "areaUnit",
    "resultKm2", "resultMi2", "resultHa", "resultAcre", "resultClass"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const pop = parseFloat(this.populationTarget.value)
    const area = parseFloat(this.areaTarget.value)
    const unit = this.areaUnitTarget.value

    if (!Number.isFinite(pop) || pop <= 0 || !Number.isFinite(area) || area <= 0) {
      this.clear()
      return
    }

    const toKm2 = {
      km2: 1,
      mi2: 2.58999,
      ha: 1 / 100,
      acre: 0.00404686,
      m2: 1 / 1_000_000
    }

    const areaKm2 = area * (toKm2[unit] || 0)
    if (areaKm2 <= 0) { this.clear(); return }

    const perKm2 = pop / areaKm2
    const areaMi2 = areaKm2 / 2.58999
    const perMi2 = pop / areaMi2

    this.resultKm2Target.textContent = perKm2.toLocaleString(undefined, { maximumFractionDigits: 2 })
    this.resultMi2Target.textContent = perMi2.toLocaleString(undefined, { maximumFractionDigits: 2 })
    this.resultHaTarget.textContent = (perKm2 / 100).toLocaleString(undefined, { maximumFractionDigits: 4 })
    this.resultAcreTarget.textContent = (perMi2 / 640).toLocaleString(undefined, { maximumFractionDigits: 4 })
    this.resultClassTarget.textContent = this.classify(perKm2)
  }

  classify(d) {
    if (d < 10) return "Very sparse (wilderness/rural)"
    if (d < 100) return "Sparse (rural)"
    if (d < 500) return "Moderate (suburban)"
    if (d < 2000) return "Dense (urban)"
    if (d < 10000) return "Very dense (inner city)"
    return "Hyperdense (megacity core)"
  }

  clear() {
    this.resultKm2Target.textContent = "0"
    this.resultMi2Target.textContent = "0"
    this.resultHaTarget.textContent = "0"
    this.resultAcreTarget.textContent = "0"
    this.resultClassTarget.textContent = "—"
  }

  copy() {
    const text = `Population Density:\nPer km²: ${this.resultKm2Target.textContent}\nPer mi²: ${this.resultMi2Target.textContent}\nClassification: ${this.resultClassTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
