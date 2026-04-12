import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "latitude", "longitude", "date", "timezoneOffset",
    "resultSunrise", "resultSunset", "resultSolarNoon", "resultDayLength",
    "resultMorningGoldenStart", "resultMorningGoldenEnd",
    "resultEveningGoldenStart", "resultEveningGoldenEnd",
    "resultMorningBlueStart", "resultMorningBlueEnd",
    "resultEveningBlueStart", "resultEveningBlueEnd"
  ]

  static values = {
    degToRad: { type: Number, default: Math.PI / 180 },
    radToDeg: { type: Number, default: 180 / Math.PI }
  }

  connect() {
    // Default to today's date
    if (!this.dateTarget.value) {
      this.dateTarget.value = new Date().toISOString().split("T")[0]
    }
  }

  calculate() {
    const lat = parseFloat(this.latitudeTarget.value)
    const lon = parseFloat(this.longitudeTarget.value)
    const dateStr = this.dateTarget.value
    const tzOffset = parseFloat(this.timezoneOffsetTarget.value) || 0

    if (isNaN(lat) || isNaN(lon) || !dateStr) {
      this.clearResults()
      return
    }

    const date = new Date(dateStr + "T12:00:00Z")
    const dayOfYear = this.getDayOfYear(date)

    const sunrise = this.timeForAngle(lat, lon, dayOfYear, -0.833, "rise", tzOffset)
    const sunset = this.timeForAngle(lat, lon, dayOfYear, -0.833, "set", tzOffset)
    const solarNoon = this.calcSolarNoon(lon, dayOfYear, tzOffset)

    // Golden hour: sun between -4 and +6 degrees
    const mGoldenStart = this.timeForAngle(lat, lon, dayOfYear, -4, "rise", tzOffset)
    const mGoldenEnd = this.timeForAngle(lat, lon, dayOfYear, 6, "rise", tzOffset)
    const eGoldenStart = this.timeForAngle(lat, lon, dayOfYear, 6, "set", tzOffset)
    const eGoldenEnd = this.timeForAngle(lat, lon, dayOfYear, -4, "set", tzOffset)

    // Blue hour: sun between -6 and -4 degrees
    const mBlueStart = this.timeForAngle(lat, lon, dayOfYear, -6, "rise", tzOffset)
    const mBlueEnd = this.timeForAngle(lat, lon, dayOfYear, -4, "rise", tzOffset)
    const eBlueStart = this.timeForAngle(lat, lon, dayOfYear, -4, "set", tzOffset)
    const eBlueEnd = this.timeForAngle(lat, lon, dayOfYear, -6, "set", tzOffset)

    this.resultSunriseTarget.textContent = this.formatTime(sunrise)
    this.resultSunsetTarget.textContent = this.formatTime(sunset)
    this.resultSolarNoonTarget.textContent = this.formatTime(solarNoon)

    if (sunrise !== null && sunset !== null) {
      const dayLen = sunset - sunrise
      const h = Math.floor(dayLen)
      const m = Math.round((dayLen - h) * 60)
      this.resultDayLengthTarget.textContent = `${h}h ${String(m).padStart(2, "0")}m`
    } else {
      this.resultDayLengthTarget.textContent = "N/A"
    }

    this.resultMorningGoldenStartTarget.textContent = this.formatTime(mGoldenStart)
    this.resultMorningGoldenEndTarget.textContent = this.formatTime(mGoldenEnd)
    this.resultEveningGoldenStartTarget.textContent = this.formatTime(eGoldenStart)
    this.resultEveningGoldenEndTarget.textContent = this.formatTime(eGoldenEnd)
    this.resultMorningBlueStartTarget.textContent = this.formatTime(mBlueStart)
    this.resultMorningBlueEndTarget.textContent = this.formatTime(mBlueEnd)
    this.resultEveningBlueStartTarget.textContent = this.formatTime(eBlueStart)
    this.resultEveningBlueEndTarget.textContent = this.formatTime(eBlueEnd)
  }

  timeForAngle(lat, lon, dayOfYear, targetAngle, riseOrSet, tzOffset) {
    const degToRad = Math.PI / 180
    const radToDeg = 180 / Math.PI
    const latRad = lat * degToRad

    // Solar declination
    const declination = 23.45 * Math.sin((360 / 365 * (dayOfYear - 81)) * degToRad) * degToRad

    // Hour angle
    const cosHA = (Math.sin(targetAngle * degToRad) - Math.sin(latRad) * Math.sin(declination)) /
                  (Math.cos(latRad) * Math.cos(declination))

    if (Math.abs(cosHA) > 1) return null

    const hourAngle = Math.acos(cosHA) * radToDeg

    // Equation of time
    const b = (360 / 365 * (dayOfYear - 81)) * degToRad
    const eot = 9.87 * Math.sin(2 * b) - 7.53 * Math.cos(b) - 1.5 * Math.sin(b)

    const solarNoonUtc = 12 - (lon / 15) - (eot / 60)

    if (riseOrSet === "rise") {
      return solarNoonUtc - (hourAngle / 15) + tzOffset
    } else {
      return solarNoonUtc + (hourAngle / 15) + tzOffset
    }
  }

  calcSolarNoon(lon, dayOfYear, tzOffset) {
    const b = (360 / 365 * (dayOfYear - 81)) * (Math.PI / 180)
    const eot = 9.87 * Math.sin(2 * b) - 7.53 * Math.cos(b) - 1.5 * Math.sin(b)
    return 12 - (lon / 15) - (eot / 60) + tzOffset
  }

  getDayOfYear(date) {
    const start = new Date(date.getUTCFullYear(), 0, 0)
    const diff = date - start
    return Math.floor(diff / (1000 * 60 * 60 * 24))
  }

  formatTime(decimalHours) {
    if (decimalHours === null) return "N/A"
    decimalHours = ((decimalHours % 24) + 24) % 24
    let hours = Math.floor(decimalHours)
    let minutes = Math.round((decimalHours - hours) * 60)
    if (minutes === 60) { hours++; minutes = 0 }
    hours = hours % 24
    return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}`
  }

  clearResults() {
    const targets = [
      "resultSunrise", "resultSunset", "resultSolarNoon", "resultDayLength",
      "resultMorningGoldenStart", "resultMorningGoldenEnd",
      "resultEveningGoldenStart", "resultEveningGoldenEnd",
      "resultMorningBlueStart", "resultMorningBlueEnd",
      "resultEveningBlueStart", "resultEveningBlueEnd"
    ]
    targets.forEach(t => { this[`${t}Target`].textContent = "—" })
  }

  copy() {
    const text = `Golden Hour Results:\nSunrise: ${this.resultSunriseTarget.textContent}\nSunset: ${this.resultSunsetTarget.textContent}\nMorning Golden: ${this.resultMorningGoldenStartTarget.textContent} - ${this.resultMorningGoldenEndTarget.textContent}\nEvening Golden: ${this.resultEveningGoldenStartTarget.textContent} - ${this.resultEveningGoldenEndTarget.textContent}\nMorning Blue: ${this.resultMorningBlueStartTarget.textContent} - ${this.resultMorningBlueEndTarget.textContent}\nEvening Blue: ${this.resultEveningBlueStartTarget.textContent} - ${this.resultEveningBlueEndTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
