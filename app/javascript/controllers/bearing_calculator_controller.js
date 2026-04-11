import { Controller } from "@hotwired/stimulus"

const COMPASS = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]

export default class extends Controller {
  static targets = ["lat1", "lon1", "lat2", "lon2", "resultBearing", "resultCompass", "resultBack", "resultBackCompass"]

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
        Math.abs(lon1) > 180 || Math.abs(lon2) > 180 ||
        (lat1 === lat2 && lon1 === lon2)) {
      this.clear()
      return
    }

    const toRad = (d) => (d * Math.PI) / 180
    const toDeg = (r) => (r * 180) / Math.PI

    const phi1 = toRad(lat1)
    const phi2 = toRad(lat2)
    const dLambda = toRad(lon2 - lon1)

    const y = Math.sin(dLambda) * Math.cos(phi2)
    const x = Math.cos(phi1) * Math.sin(phi2) - Math.sin(phi1) * Math.cos(phi2) * Math.cos(dLambda)

    const bearing = (toDeg(Math.atan2(y, x)) + 360) % 360
    const back = (bearing + 180) % 360

    this.resultBearingTarget.textContent = `${bearing.toFixed(2)}°`
    this.resultCompassTarget.textContent = this.compass(bearing)
    this.resultBackTarget.textContent = `${back.toFixed(2)}°`
    this.resultBackCompassTarget.textContent = this.compass(back)
  }

  compass(bearing) {
    return COMPASS[Math.floor((bearing / 22.5) + 0.5) % 16]
  }

  clear() {
    this.resultBearingTarget.textContent = "—"
    this.resultCompassTarget.textContent = ""
    this.resultBackTarget.textContent = "—"
    this.resultBackCompassTarget.textContent = ""
  }

  copy() {
    const text = `Bearing:\nInitial: ${this.resultBearingTarget.textContent} ${this.resultCompassTarget.textContent}\nBack: ${this.resultBackTarget.textContent} ${this.resultBackCompassTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
