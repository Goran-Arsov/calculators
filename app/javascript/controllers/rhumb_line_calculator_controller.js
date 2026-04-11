import { Controller } from "@hotwired/stimulus"

const R_KM = 6371.0088
const COMPASS = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]

export default class extends Controller {
  static targets = ["lat1", "lon1", "lat2", "lon2", "resultKm", "resultMiles", "resultNm", "resultBearing", "resultCompass"]

  connect() {
    this.calculate()
  }

  calculate() {
    const lat1 = parseFloat(this.lat1Target.value)
    const lon1 = parseFloat(this.lon1Target.value)
    const lat2 = parseFloat(this.lat2Target.value)
    const lon2 = parseFloat(this.lon2Target.value)

    if (![lat1, lon1, lat2, lon2].every(Number.isFinite) ||
        Math.abs(lat1) > 90 || Math.abs(lat2) > 90 ||
        Math.abs(lon1) > 180 || Math.abs(lon2) > 180) {
      this.clear()
      return
    }

    const toRad = (d) => (d * Math.PI) / 180
    const toDeg = (r) => (r * 180) / Math.PI

    const phi1 = toRad(lat1)
    const phi2 = toRad(lat2)
    const dPhi = phi2 - phi1

    let dLambda = lon2 - lon1
    while (dLambda > 180) dLambda -= 360
    while (dLambda < -180) dLambda += 360
    dLambda = toRad(dLambda)

    const dPsi = Math.log(Math.tan(Math.PI / 4 + phi2 / 2) / Math.tan(Math.PI / 4 + phi1 / 2))
    const q = Math.abs(dPsi) > 1e-12 ? dPhi / dPsi : Math.cos(phi1)

    const distKm = Math.sqrt(dPhi ** 2 + q ** 2 * dLambda ** 2) * R_KM
    const bearing = (toDeg(Math.atan2(dLambda, dPsi)) + 360) % 360

    this.resultKmTarget.textContent = `${distKm.toFixed(3)} km`
    this.resultMilesTarget.textContent = `${(distKm * 0.621371).toFixed(3)} mi`
    this.resultNmTarget.textContent = `${(distKm * 0.539957).toFixed(3)} nm`
    this.resultBearingTarget.textContent = `${bearing.toFixed(2)}°`
    this.resultCompassTarget.textContent = COMPASS[Math.floor((bearing / 22.5) + 0.5) % 16]
  }

  clear() {
    this.resultKmTarget.textContent = "0 km"
    this.resultMilesTarget.textContent = "0 mi"
    this.resultNmTarget.textContent = "0 nm"
    this.resultBearingTarget.textContent = "—"
    this.resultCompassTarget.textContent = ""
  }

  copy() {
    const text = `Rhumb Line:\nDistance: ${this.resultKmTarget.textContent} (${this.resultNmTarget.textContent})\nBearing: ${this.resultBearingTarget.textContent} ${this.resultCompassTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
