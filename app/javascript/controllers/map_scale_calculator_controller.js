import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "scaleRatio", "mapDistance", "mapUnit",
    "resultMeters", "resultKm", "resultMiles", "resultFeet", "resultYards"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const ratio = parseFloat(this.scaleRatioTarget.value)
    const mapDistance = parseFloat(this.mapDistanceTarget.value)
    const unit = this.mapUnitTarget.value

    if (!Number.isFinite(ratio) || ratio <= 0 || !Number.isFinite(mapDistance) || mapDistance <= 0) {
      this.clear()
      return
    }

    const toMeters = { cm: 0.01, mm: 0.001, in: 0.0254 }
    const mapMeters = mapDistance * (toMeters[unit] || 0)
    const realMeters = mapMeters * ratio

    this.resultMetersTarget.textContent = `${realMeters.toFixed(2)} m`
    this.resultKmTarget.textContent = `${(realMeters / 1000).toFixed(4)} km`
    this.resultMilesTarget.textContent = `${(realMeters / 1609.344).toFixed(4)} mi`
    this.resultFeetTarget.textContent = `${(realMeters * 3.28084).toFixed(2)} ft`
    this.resultYardsTarget.textContent = `${(realMeters * 1.09361).toFixed(2)} yd`
  }

  clear() {
    this.resultMetersTarget.textContent = "0 m"
    this.resultKmTarget.textContent = "0 km"
    this.resultMilesTarget.textContent = "0 mi"
    this.resultFeetTarget.textContent = "0 ft"
    this.resultYardsTarget.textContent = "0 yd"
  }

  copy() {
    const text = `Map Scale Conversion:\n${this.resultMetersTarget.textContent}\n${this.resultKmTarget.textContent}\n${this.resultMilesTarget.textContent}\n${this.resultFeetTarget.textContent}\n${this.resultYardsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
