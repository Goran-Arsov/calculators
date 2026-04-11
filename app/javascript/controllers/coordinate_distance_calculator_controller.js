import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lat1", "lon1", "lat2", "lon2", "resultKm", "resultMiles", "resultNm", "resultMeters"]

  connect() {
    this.calculate()
  }

  calculate() {
    const lat1 = parseFloat(this.lat1Target.value)
    const lon1 = parseFloat(this.lon1Target.value)
    const lat2 = parseFloat(this.lat2Target.value)
    const lon2 = parseFloat(this.lon2Target.value)

    if (![lat1, lon1, lat2, lon2].every(Number.isFinite)) {
      this.clear()
      return
    }
    if (Math.abs(lat1) > 90 || Math.abs(lat2) > 90 || Math.abs(lon1) > 180 || Math.abs(lon2) > 180) {
      this.clear()
      return
    }

    const R = 6371.0088
    const toRad = (d) => (d * Math.PI) / 180
    const phi1 = toRad(lat1)
    const phi2 = toRad(lat2)
    const dPhi = toRad(lat2 - lat1)
    const dLambda = toRad(lon2 - lon1)

    const a =
      Math.sin(dPhi / 2) ** 2 +
      Math.cos(phi1) * Math.cos(phi2) * Math.sin(dLambda / 2) ** 2
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    const km = R * c

    this.resultKmTarget.textContent = `${km.toFixed(3)} km`
    this.resultMilesTarget.textContent = `${(km * 0.621371).toFixed(3)} mi`
    this.resultNmTarget.textContent = `${(km * 0.539957).toFixed(3)} nm`
    this.resultMetersTarget.textContent = `${(km * 1000).toFixed(1)} m`
  }

  clear() {
    this.resultKmTarget.textContent = "0 km"
    this.resultMilesTarget.textContent = "0 mi"
    this.resultNmTarget.textContent = "0 nm"
    this.resultMetersTarget.textContent = "0 m"
  }

  copy() {
    const text = `Coordinate Distance:\n${this.resultKmTarget.textContent}\n${this.resultMilesTarget.textContent}\n${this.resultNmTarget.textContent}\n${this.resultMetersTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
