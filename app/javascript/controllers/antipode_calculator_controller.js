import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lat", "lon", "resultLat", "resultLon", "resultNote"]

  connect() {
    this.calculate()
  }

  calculate() {
    const lat = parseFloat(this.latTarget.value)
    const lon = parseFloat(this.lonTarget.value)

    if (!Number.isFinite(lat) || !Number.isFinite(lon) ||
        Math.abs(lat) > 90 || Math.abs(lon) > 180) {
      this.clear()
      return
    }

    const antipodeLat = -lat
    let antipodeLon = lon + 180
    if (antipodeLon > 180) antipodeLon -= 360
    if (antipodeLon < -180) antipodeLon += 360

    this.resultLatTarget.textContent = `${antipodeLat.toFixed(6)}° ${antipodeLat < 0 ? "S" : "N"}`
    this.resultLonTarget.textContent = `${antipodeLon.toFixed(6)}° ${antipodeLon < 0 ? "W" : "E"}`
    this.resultNoteTarget.textContent = this.likelyOcean(antipodeLat, antipodeLon) ? "Likely in ocean" : "Possibly on land"
  }

  likelyOcean(lat, lon) {
    // Same rough heuristic as the PORO.
    if (lat >= -55 && lat <= -30 && lon >= 110 && lon <= 150) return false
    if (lat >= 30 && lat <= 55 && lon >= 100 && lon <= 140) return false
    return true
  }

  clear() {
    this.resultLatTarget.textContent = "—"
    this.resultLonTarget.textContent = "—"
    this.resultNoteTarget.textContent = "—"
  }

  copy() {
    const text = `Antipode:\nLat: ${this.resultLatTarget.textContent}\nLon: ${this.resultLonTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
