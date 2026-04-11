import { Controller } from "@hotwired/stimulus"

const BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz"

export default class extends Controller {
  static targets = [
    "tabEncode", "tabDecode", "encodeInputs", "decodeInputs",
    "lat", "lon", "precision", "geohash",
    "resultHash", "resultLat", "resultLon", "resultError"
  ]

  connect() {
    this.mode = "encode"
    this.calculate()
  }

  showEncode() {
    this.mode = "encode"
    this.encodeInputsTarget.classList.remove("hidden")
    this.decodeInputsTarget.classList.add("hidden")
    this.tabEncodeTarget.className = "px-4 py-2 rounded-lg bg-blue-600 text-white text-sm font-semibold"
    this.tabDecodeTarget.className = "px-4 py-2 rounded-lg bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 text-sm font-semibold"
    this.calculate()
  }

  showDecode() {
    this.mode = "decode"
    this.encodeInputsTarget.classList.add("hidden")
    this.decodeInputsTarget.classList.remove("hidden")
    this.tabEncodeTarget.className = "px-4 py-2 rounded-lg bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 text-sm font-semibold"
    this.tabDecodeTarget.className = "px-4 py-2 rounded-lg bg-blue-600 text-white text-sm font-semibold"
    this.calculate()
  }

  calculate() {
    if (this.mode === "encode") {
      this.encode()
    } else {
      this.decode()
    }
  }

  encode() {
    const lat = parseFloat(this.latTarget.value)
    const lon = parseFloat(this.lonTarget.value)
    const precision = parseInt(this.precisionTarget.value)

    if (!Number.isFinite(lat) || !Number.isFinite(lon) ||
        Math.abs(lat) > 90 || Math.abs(lon) > 180 ||
        !Number.isFinite(precision) || precision < 1 || precision > 12) {
      this.clear()
      return
    }

    let latRange = [-90.0, 90.0]
    let lonRange = [-180.0, 180.0]
    const bits = []
    let even = true

    while (bits.length < precision * 5) {
      if (even) {
        const mid = (lonRange[0] + lonRange[1]) / 2
        if (lon >= mid) { bits.push(1); lonRange[0] = mid } else { bits.push(0); lonRange[1] = mid }
      } else {
        const mid = (latRange[0] + latRange[1]) / 2
        if (lat >= mid) { bits.push(1); latRange[0] = mid } else { bits.push(0); latRange[1] = mid }
      }
      even = !even
    }

    let hash = ""
    for (let i = 0; i < bits.length; i += 5) {
      let n = 0
      for (let j = 0; j < 5; j++) n = (n << 1) | bits[i + j]
      hash += BASE32[n]
    }

    const centerLat = (latRange[0] + latRange[1]) / 2
    const centerLon = (lonRange[0] + lonRange[1]) / 2
    const latErr = (latRange[1] - latRange[0]) / 2
    const lonErr = (lonRange[1] - lonRange[0]) / 2

    this.resultHashTarget.textContent = hash
    this.resultLatTarget.textContent = centerLat.toFixed(8)
    this.resultLonTarget.textContent = centerLon.toFixed(8)
    this.resultErrorTarget.textContent = `±${latErr.toFixed(8)}° lat, ±${lonErr.toFixed(8)}° lon`
  }

  decode() {
    const hash = this.geohashTarget.value.toLowerCase().trim()
    if (hash.length === 0 || hash.length > 12) {
      this.clear()
      return
    }
    if (![...hash].every(c => BASE32.includes(c))) {
      this.clear()
      this.resultHashTarget.textContent = "Invalid"
      return
    }

    let latRange = [-90.0, 90.0]
    let lonRange = [-180.0, 180.0]
    let even = true

    for (const char of hash) {
      const index = BASE32.indexOf(char)
      for (let i = 0; i < 5; i++) {
        const bit = (index >> (4 - i)) & 1
        if (even) {
          const mid = (lonRange[0] + lonRange[1]) / 2
          if (bit === 1) lonRange[0] = mid; else lonRange[1] = mid
        } else {
          const mid = (latRange[0] + latRange[1]) / 2
          if (bit === 1) latRange[0] = mid; else latRange[1] = mid
        }
        even = !even
      }
    }

    const centerLat = (latRange[0] + latRange[1]) / 2
    const centerLon = (lonRange[0] + lonRange[1]) / 2
    const latErr = (latRange[1] - latRange[0]) / 2
    const lonErr = (lonRange[1] - lonRange[0]) / 2

    this.resultHashTarget.textContent = hash
    this.resultLatTarget.textContent = centerLat.toFixed(8)
    this.resultLonTarget.textContent = centerLon.toFixed(8)
    this.resultErrorTarget.textContent = `±${latErr.toFixed(8)}° lat, ±${lonErr.toFixed(8)}° lon`
  }

  clear() {
    this.resultHashTarget.textContent = "—"
    this.resultLatTarget.textContent = "—"
    this.resultLonTarget.textContent = "—"
    this.resultErrorTarget.textContent = "—"
  }

  copy() {
    const text = `GeoHash:\n${this.resultHashTarget.textContent}\nLat: ${this.resultLatTarget.textContent}\nLon: ${this.resultLonTarget.textContent}\nError: ${this.resultErrorTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
