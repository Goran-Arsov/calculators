import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lat1", "lon1", "lat2", "lon2", "resultLat", "resultLon"]

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
    const lambda1 = toRad(lon1)
    const dLambda = toRad(lon2 - lon1)

    const bx = Math.cos(phi2) * Math.cos(dLambda)
    const by = Math.cos(phi2) * Math.sin(dLambda)

    const midLat = Math.atan2(
      Math.sin(phi1) + Math.sin(phi2),
      Math.sqrt((Math.cos(phi1) + bx) ** 2 + by ** 2)
    )
    const midLon = lambda1 + Math.atan2(by, Math.cos(phi1) + bx)
    const midLonDeg = ((toDeg(midLon) + 540) % 360) - 180

    this.resultLatTarget.textContent = toDeg(midLat).toFixed(6)
    this.resultLonTarget.textContent = midLonDeg.toFixed(6)
  }

  clear() {
    this.resultLatTarget.textContent = "—"
    this.resultLonTarget.textContent = "—"
  }

  copy() {
    const text = `Midpoint:\nLatitude: ${this.resultLatTarget.textContent}\nLongitude: ${this.resultLonTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
