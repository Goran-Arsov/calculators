import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "tabDms", "tabDec", "dmsInputs", "decimalInputs",
    "latDeg", "latMin", "latSec", "latHemi",
    "lonDeg", "lonMin", "lonSec", "lonHemi",
    "decLat", "decLon",
    "resultDecLat", "resultDecLon", "resultDmsLat", "resultDmsLon"
  ]

  connect() {
    this.mode = "dms"
    this.calculate()
  }

  showDms() {
    this.mode = "dms"
    this.dmsInputsTarget.classList.remove("hidden")
    this.decimalInputsTarget.classList.add("hidden")
    this.tabDmsTarget.className = "px-4 py-2 rounded-lg bg-blue-600 text-white text-sm font-semibold"
    this.tabDecTarget.className = "px-4 py-2 rounded-lg bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 text-sm font-semibold"
    this.calculate()
  }

  showDecimal() {
    this.mode = "decimal"
    this.dmsInputsTarget.classList.add("hidden")
    this.decimalInputsTarget.classList.remove("hidden")
    this.tabDmsTarget.className = "px-4 py-2 rounded-lg bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 text-sm font-semibold"
    this.tabDecTarget.className = "px-4 py-2 rounded-lg bg-blue-600 text-white text-sm font-semibold"
    this.calculate()
  }

  calculate() {
    if (this.mode === "dms") {
      this.dmsToDecimal()
    } else {
      this.decimalToDms()
    }
  }

  dmsToDecimal() {
    const latDeg = parseFloat(this.latDegTarget.value) || 0
    const latMin = parseFloat(this.latMinTarget.value) || 0
    const latSec = parseFloat(this.latSecTarget.value) || 0
    const lonDeg = parseFloat(this.lonDegTarget.value) || 0
    const lonMin = parseFloat(this.lonMinTarget.value) || 0
    const lonSec = parseFloat(this.lonSecTarget.value) || 0
    const latHemi = this.latHemiTarget.value
    const lonHemi = this.lonHemiTarget.value

    let lat = latDeg + latMin / 60 + latSec / 3600
    if (latHemi === "S") lat = -lat
    let lon = lonDeg + lonMin / 60 + lonSec / 3600
    if (lonHemi === "W") lon = -lon

    this.resultDecLatTarget.textContent = lat.toFixed(6)
    this.resultDecLonTarget.textContent = lon.toFixed(6)
    this.resultDmsLatTarget.textContent = `${latDeg}°${latMin}'${latSec}"${latHemi}`
    this.resultDmsLonTarget.textContent = `${lonDeg}°${lonMin}'${lonSec}"${lonHemi}`
  }

  decimalToDms() {
    const lat = parseFloat(this.decLatTarget.value)
    const lon = parseFloat(this.decLonTarget.value)

    if (!Number.isFinite(lat) || !Number.isFinite(lon) ||
        Math.abs(lat) > 90 || Math.abs(lon) > 180) {
      this.resultDecLatTarget.textContent = "—"
      this.resultDecLonTarget.textContent = "—"
      this.resultDmsLatTarget.textContent = "—"
      this.resultDmsLonTarget.textContent = "—"
      return
    }

    const latDms = this.toDms(lat, lat < 0 ? "S" : "N")
    const lonDms = this.toDms(lon, lon < 0 ? "W" : "E")

    this.resultDecLatTarget.textContent = lat.toFixed(6)
    this.resultDecLonTarget.textContent = lon.toFixed(6)
    this.resultDmsLatTarget.textContent = `${latDms.deg}°${latDms.min}'${latDms.sec}"${latDms.hemi}`
    this.resultDmsLonTarget.textContent = `${lonDms.deg}°${lonDms.min}'${lonDms.sec}"${lonDms.hemi}`
  }

  toDms(value, hemi) {
    const abs = Math.abs(value)
    const deg = Math.floor(abs)
    const minFull = (abs - deg) * 60
    const min = Math.floor(minFull)
    const sec = ((minFull - min) * 60).toFixed(3)
    return { deg, min, sec, hemi }
  }

  copy() {
    const text = `Coordinates:\nDecimal: ${this.resultDecLatTarget.textContent}, ${this.resultDecLonTarget.textContent}\nDMS: ${this.resultDmsLatTarget.textContent}, ${this.resultDmsLonTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
