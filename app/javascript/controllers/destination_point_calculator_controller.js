import { Controller } from "@hotwired/stimulus"

const R_KM = 6371.0088

const TO_KM = {
  km: 1,
  mi: 1.609344,
  nmi: 1.852,
  m: 0.001
}

export default class extends Controller {
  static targets = ["lat", "lon", "bearing", "distance", "distanceUnit", "resultLat", "resultLon"]

  connect() {
    this.calculate()
  }

  calculate() {
    const lat = parseFloat(this.latTarget.value)
    const lon = parseFloat(this.lonTarget.value)
    const bearing = parseFloat(this.bearingTarget.value)
    const distance = parseFloat(this.distanceTarget.value)
    const unit = this.distanceUnitTarget.value

    if (![lat, lon, bearing, distance].every(Number.isFinite) ||
        Math.abs(lat) > 90 || Math.abs(lon) > 180 ||
        bearing < 0 || bearing > 360 || distance <= 0) {
      this.clear()
      return
    }

    const distanceKm = distance * (TO_KM[unit] || 0)
    const angular = distanceKm / R_KM
    const toRad = (d) => (d * Math.PI) / 180
    const toDeg = (r) => (r * 180) / Math.PI

    const phi1 = toRad(lat)
    const lambda1 = toRad(lon)
    const theta = toRad(bearing)

    const phi2 = Math.asin(
      Math.sin(phi1) * Math.cos(angular) +
      Math.cos(phi1) * Math.sin(angular) * Math.cos(theta)
    )
    const lambda2 = lambda1 + Math.atan2(
      Math.sin(theta) * Math.sin(angular) * Math.cos(phi1),
      Math.cos(angular) - Math.sin(phi1) * Math.sin(phi2)
    )

    const destLat = toDeg(phi2)
    const destLon = ((toDeg(lambda2) + 540) % 360) - 180

    this.resultLatTarget.textContent = destLat.toFixed(6)
    this.resultLonTarget.textContent = destLon.toFixed(6)
  }

  clear() {
    this.resultLatTarget.textContent = "—"
    this.resultLonTarget.textContent = "—"
  }

  copy() {
    const text = `Destination:\nLat: ${this.resultLatTarget.textContent}\nLon: ${this.resultLonTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
