import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "hour", "minute", "sourceZone", "targetZone",
    "resultTime", "resultOffset", "resultDayShift"
  ]

  static timezones = {
    "UTC": 0, "EST": -5, "EDT": -4, "CST": -6, "CDT": -5,
    "MST": -7, "MDT": -6, "PST": -8, "PDT": -7,
    "AKST": -9, "AKDT": -8, "HST": -10,
    "GMT": 0, "BST": 1, "CET": 1, "CEST": 2,
    "EET": 2, "EEST": 3, "MSK": 3, "IST": 5.5,
    "ICT": 7, "CST_CN": 8, "JST": 9, "KST": 9,
    "AEST": 10, "AEDT": 11, "NZST": 12, "NZDT": 13
  }

  calculate() {
    const hour = parseInt(this.hourTarget.value) || 0
    const minute = parseInt(this.minuteTarget.value) || 0
    const sourceZone = this.sourceZoneTarget.value
    const targetZone = this.targetZoneTarget.value

    const tz = this.constructor.timezones
    if (!(sourceZone in tz) || !(targetZone in tz)) return

    const offsetDiff = tz[targetZone] - tz[sourceZone]
    let totalMinutes = hour * 60 + minute + Math.round(offsetDiff * 60)
    let dayShift = 0

    if (totalMinutes < 0) {
      dayShift = -1
      totalMinutes += 1440
    } else if (totalMinutes >= 1440) {
      dayShift = 1
      totalMinutes -= 1440
    }

    const convHour = Math.floor(totalMinutes / 60)
    const convMinute = totalMinutes % 60

    const formatted = String(convHour).padStart(2, "0") + ":" + String(convMinute).padStart(2, "0")
    this.resultTimeTarget.textContent = formatted

    const sign = offsetDiff >= 0 ? "+" : ""
    this.resultOffsetTarget.textContent = sign + offsetDiff + " hours"

    if (dayShift === 1) {
      this.resultDayShiftTarget.textContent = "Next day"
    } else if (dayShift === -1) {
      this.resultDayShiftTarget.textContent = "Previous day"
    } else {
      this.resultDayShiftTarget.textContent = "Same day"
    }
  }

  copy() {
    const time = this.resultTimeTarget.textContent
    const offset = this.resultOffsetTarget.textContent
    const day = this.resultDayShiftTarget.textContent
    const text = `Converted Time: ${time}\nOffset: ${offset}\nDay: ${day}`
    navigator.clipboard.writeText(text)
  }
}
