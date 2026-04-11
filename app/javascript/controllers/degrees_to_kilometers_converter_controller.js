import { Controller } from "@hotwired/stimulus"

const KM_PER_DEGREE_LATITUDE = 111.32

export default class extends Controller {
  static targets = ["latitude", "degrees", "resultLatKm", "resultLonKm", "resultInputLat", "resultInputLon"]

  connect() {
    this.calculate()
  }

  calculate() {
    const lat = parseFloat(this.latitudeTarget.value)
    const degrees = parseFloat(this.degreesTarget.value)

    if (!Number.isFinite(lat) || Math.abs(lat) > 90 || !Number.isFinite(degrees) || degrees <= 0) {
      this.clear()
      return
    }

    const toRad = (d) => (d * Math.PI) / 180
    const kmPerDegLat = KM_PER_DEGREE_LATITUDE
    const kmPerDegLon = KM_PER_DEGREE_LATITUDE * Math.cos(toRad(lat))

    this.resultLatKmTarget.textContent = `${kmPerDegLat.toFixed(4)} km / ${(kmPerDegLat * 0.621371).toFixed(4)} mi`
    this.resultLonKmTarget.textContent = `${kmPerDegLon.toFixed(4)} km / ${(kmPerDegLon * 0.621371).toFixed(4)} mi`
    this.resultInputLatTarget.textContent = `${(degrees * kmPerDegLat).toFixed(4)} km lat`
    this.resultInputLonTarget.textContent = `${(degrees * kmPerDegLon).toFixed(4)} km lon`
  }

  clear() {
    this.resultLatKmTarget.textContent = "0 km"
    this.resultLonKmTarget.textContent = "0 km"
    this.resultInputLatTarget.textContent = "0 km lat"
    this.resultInputLonTarget.textContent = "0 km lon"
  }

  copy() {
    const text = `Degrees to Kilometers:\n1° lat = ${this.resultLatKmTarget.textContent}\n1° lon = ${this.resultLonKmTarget.textContent}\nInput: ${this.resultInputLatTarget.textContent}, ${this.resultInputLonTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
