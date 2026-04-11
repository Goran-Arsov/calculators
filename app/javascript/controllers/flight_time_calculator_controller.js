import { Controller } from "@hotwired/stimulus"

const R_KM = 6371.0088

const AIRCRAFT_SPEEDS = {
  commercial_jet: 900,
  regional_jet: 780,
  turboprop: 520,
  private_jet: 780,
  cessna: 230,
  helicopter: 260
}

export default class extends Controller {
  static targets = ["lat1", "lon1", "lat2", "lon2", "aircraft", "taxi", "resultFormatted", "resultAir", "resultKm", "resultMi", "resultNm"]

  connect() {
    this.calculate()
  }

  calculate() {
    const lat1 = parseFloat(this.lat1Target.value)
    const lon1 = parseFloat(this.lon1Target.value)
    const lat2 = parseFloat(this.lat2Target.value)
    const lon2 = parseFloat(this.lon2Target.value)
    const aircraft = this.aircraftTarget.value
    const taxi = parseFloat(this.taxiTarget.value)

    if (![lat1, lon1, lat2, lon2].every(Number.isFinite) ||
        Math.abs(lat1) > 90 || Math.abs(lat2) > 90 ||
        Math.abs(lon1) > 180 || Math.abs(lon2) > 180 ||
        !Number.isFinite(taxi) || taxi < 0) {
      this.clear()
      return
    }

    const cruiseSpeed = AIRCRAFT_SPEEDS[aircraft] || 900
    const distKm = this.haversine(lat1, lon1, lat2, lon2)
    const airHours = distKm / cruiseSpeed
    const totalHours = airHours + taxi / 60

    this.resultFormattedTarget.textContent = this.formatHm(totalHours)
    this.resultAirTarget.textContent = `${airHours.toFixed(2)}h`
    this.resultKmTarget.textContent = `${distKm.toFixed(2)} km`
    this.resultMiTarget.textContent = `${(distKm * 0.621371).toFixed(2)} mi`
    this.resultNmTarget.textContent = `${(distKm * 0.539957).toFixed(2)} nm`
  }

  haversine(lat1, lon1, lat2, lon2) {
    const toRad = (d) => (d * Math.PI) / 180
    const phi1 = toRad(lat1)
    const phi2 = toRad(lat2)
    const dPhi = toRad(lat2 - lat1)
    const dLambda = toRad(lon2 - lon1)
    const a = Math.sin(dPhi / 2) ** 2 + Math.cos(phi1) * Math.cos(phi2) * Math.sin(dLambda / 2) ** 2
    return 2 * R_KM * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  }

  formatHm(hours) {
    let h = Math.floor(hours)
    let m = Math.round((hours - h) * 60)
    if (m === 60) { h += 1; m = 0 }
    return `${h}h ${m}m`
  }

  clear() {
    this.resultFormattedTarget.textContent = "0h 0m"
    this.resultAirTarget.textContent = "0h"
    this.resultKmTarget.textContent = "0 km"
    this.resultMiTarget.textContent = "0 mi"
    this.resultNmTarget.textContent = "0 nm"
  }

  copy() {
    const text = `Flight Time Estimate:\nDuration: ${this.resultFormattedTarget.textContent}\nAir time: ${this.resultAirTarget.textContent}\nDistance: ${this.resultKmTarget.textContent} (${this.resultNmTarget.textContent})`
    navigator.clipboard.writeText(text)
  }
}
