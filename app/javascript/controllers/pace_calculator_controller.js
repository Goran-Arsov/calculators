import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "distForPace", "timeForPace", "resultPace",
    "distForTime", "paceForTime", "resultTime",
    "paceForDist", "timeForDist", "resultDistance"
  ]

  calcPace() {
    const distance = parseFloat(this.distForPaceTarget.value) || 0
    const time = parseFloat(this.timeForPaceTarget.value) || 0

    if (distance <= 0 || time <= 0) {
      this.resultPaceTarget.textContent = "—"
      return
    }

    const paceMinPerKm = time / distance
    this.resultPaceTarget.textContent = this.fmtPace(paceMinPerKm) + " /km"
  }

  calcTime() {
    const distance = parseFloat(this.distForTimeTarget.value) || 0
    const paceMin = parseFloat(this.paceForTimeTarget.value) || 0

    if (distance <= 0 || paceMin <= 0) {
      this.resultTimeTarget.textContent = "—"
      return
    }

    const totalMin = distance * paceMin
    this.resultTimeTarget.textContent = this.fmtTime(totalMin)
  }

  calcDistance() {
    const paceMin = parseFloat(this.paceForDistTarget.value) || 0
    const time = parseFloat(this.timeForDistTarget.value) || 0

    if (paceMin <= 0 || time <= 0) {
      this.resultDistanceTarget.textContent = "—"
      return
    }

    const distance = time / paceMin
    this.resultDistanceTarget.textContent = this.fmt(distance) + " km"
  }

  fmtPace(decimalMinutes) {
    const min = Math.floor(decimalMinutes)
    const sec = Math.round((decimalMinutes - min) * 60)
    return min + ":" + String(sec).padStart(2, "0")
  }

  fmtTime(totalMinutes) {
    const hours = Math.floor(totalMinutes / 60)
    const min = Math.floor(totalMinutes % 60)
    const sec = Math.round((totalMinutes - Math.floor(totalMinutes)) * 60)

    if (hours > 0) {
      return hours + "h " + min + "m " + String(sec).padStart(2, "0") + "s"
    }
    return min + ":" + String(sec).padStart(2, "0")
  }

  fmt(n) {
    return n.toFixed(2)
  }
}
