import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "inputIp",
    "resultError", "resultsContainer",
    "resultIp", "resultVersion", "resultClass", "resultPrivate", "resultLoopback", "resultBinary",
    "geoContainer", "geoLoading", "geoError",
    "geoCountry", "geoCity", "geoRegion", "geoIsp", "geoTimezone", "geoLatitude", "geoLongitude"
  ]

  lookup() {
    const ip = this.inputIpTarget.value.trim()

    if (!ip) {
      this.clearResults()
      return
    }

    if (!this.isValidIp(ip)) {
      this.showError("Enter a valid IPv4 address (e.g. 192.168.1.1)")
      this.hideResults()
      return
    }

    this.hideError()
    this.showResults()
    this.hideGeo()

    const octets = ip.split(".").map(Number)
    const firstOctet = octets[0]

    this.resultIpTarget.textContent = ip
    this.resultVersionTarget.textContent = "IPv4"
    this.resultClassTarget.textContent = this.ipClass(firstOctet)
    this.resultPrivateTarget.textContent = this.isPrivate(octets) ? "Private" : "Public"
    this.resultPrivateTarget.className = this.isPrivate(octets)
      ? "px-3 py-1 text-xs font-semibold rounded-full bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300"
      : "px-3 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
    this.resultLoopbackTarget.textContent = this.isLoopback(octets) ? "Yes (Loopback)" : "No"
    this.resultBinaryTarget.textContent = octets.map(o => o.toString(2).padStart(8, "0")).join(".")
  }

  lookupGeo() {
    const ip = this.inputIpTarget.value.trim()
    if (!ip || !this.isValidIp(ip)) return

    this.geoContainerTarget.classList.remove("hidden")
    this.geoLoadingTarget.classList.remove("hidden")
    this.geoErrorTarget.classList.add("hidden")
    this.clearGeoFields()

    fetch(`https://ipapi.co/${ip}/json/`)
      .then(response => {
        if (!response.ok) throw new Error("API request failed")
        return response.json()
      })
      .then(data => {
        this.geoLoadingTarget.classList.add("hidden")
        if (data.error) {
          this.showGeoError(data.reason || "Could not retrieve geolocation data for this IP.")
          return
        }
        this.geoCountryTarget.textContent = data.country_name || "N/A"
        this.geoCityTarget.textContent = data.city || "N/A"
        this.geoRegionTarget.textContent = data.region || "N/A"
        this.geoIspTarget.textContent = data.org || "N/A"
        this.geoTimezoneTarget.textContent = data.timezone || "N/A"
        this.geoLatitudeTarget.textContent = data.latitude != null ? String(data.latitude) : "N/A"
        this.geoLongitudeTarget.textContent = data.longitude != null ? String(data.longitude) : "N/A"
      })
      .catch(() => {
        this.geoLoadingTarget.classList.add("hidden")
        this.showGeoError("Failed to fetch geolocation data. Please try again later.")
      })
  }

  lookupMyIp() {
    this.geoContainerTarget.classList.remove("hidden")
    this.geoLoadingTarget.classList.remove("hidden")
    this.geoErrorTarget.classList.add("hidden")
    this.clearGeoFields()

    fetch("https://ipapi.co/json/")
      .then(response => {
        if (!response.ok) throw new Error("API request failed")
        return response.json()
      })
      .then(data => {
        this.geoLoadingTarget.classList.add("hidden")
        if (data.error) {
          this.showGeoError(data.reason || "Could not retrieve your IP information.")
          return
        }
        // Fill in IP field and trigger local lookup
        if (data.ip) {
          this.inputIpTarget.value = data.ip
          this.lookup()
        }
        this.geoContainerTarget.classList.remove("hidden")
        this.geoCountryTarget.textContent = data.country_name || "N/A"
        this.geoCityTarget.textContent = data.city || "N/A"
        this.geoRegionTarget.textContent = data.region || "N/A"
        this.geoIspTarget.textContent = data.org || "N/A"
        this.geoTimezoneTarget.textContent = data.timezone || "N/A"
        this.geoLatitudeTarget.textContent = data.latitude != null ? String(data.latitude) : "N/A"
        this.geoLongitudeTarget.textContent = data.longitude != null ? String(data.longitude) : "N/A"
      })
      .catch(() => {
        this.geoLoadingTarget.classList.add("hidden")
        this.showGeoError("Failed to fetch your IP information. Please try again later.")
      })
  }

  isValidIp(ip) {
    const parts = ip.split(".")
    if (parts.length !== 4) return false
    return parts.every(p => {
      const n = parseInt(p, 10)
      return !isNaN(n) && n >= 0 && n <= 255 && p === String(n)
    })
  }

  ipClass(firstOctet) {
    if (firstOctet <= 127) return "A"
    if (firstOctet <= 191) return "B"
    if (firstOctet <= 223) return "C"
    if (firstOctet <= 239) return "D (Multicast)"
    return "E (Reserved)"
  }

  isPrivate(octets) {
    if (octets[0] === 10) return true
    if (octets[0] === 172 && octets[1] >= 16 && octets[1] <= 31) return true
    if (octets[0] === 192 && octets[1] === 168) return true
    return false
  }

  isLoopback(octets) {
    return octets[0] === 127
  }

  showError(message) {
    this.resultErrorTarget.textContent = message
    this.resultErrorTarget.classList.remove("hidden")
  }

  hideError() {
    this.resultErrorTarget.textContent = ""
    this.resultErrorTarget.classList.add("hidden")
  }

  showResults() {
    this.resultsContainerTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsContainerTarget.classList.add("hidden")
  }

  hideGeo() {
    this.geoContainerTarget.classList.add("hidden")
  }

  clearGeoFields() {
    const fields = ["geoCountry", "geoCity", "geoRegion", "geoIsp", "geoTimezone", "geoLatitude", "geoLongitude"]
    fields.forEach(name => {
      if (this[`has${name.charAt(0).toUpperCase() + name.slice(1)}Target`]) {
        this[`${name}Target`].textContent = ""
      }
    })
  }

  showGeoError(message) {
    this.geoErrorTarget.textContent = message
    this.geoErrorTarget.classList.remove("hidden")
  }

  clearResults() {
    this.hideError()
    this.hideResults()
    this.hideGeo()
  }

  copy() {
    const parts = [
      `IP Address: ${this.resultIpTarget.textContent}`,
      `IP Version: ${this.resultVersionTarget.textContent}`,
      `IP Class: ${this.resultClassTarget.textContent}`,
      `Private/Public: ${this.resultPrivateTarget.textContent}`,
      `Loopback: ${this.resultLoopbackTarget.textContent}`,
      `Binary: ${this.resultBinaryTarget.textContent}`
    ]
    navigator.clipboard.writeText(parts.join("\n"))
  }
}
