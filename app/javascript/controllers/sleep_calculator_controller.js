import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wakeTime", "resultBedtimes", "bedTime", "resultWakeTimes"]

  static cycleMinutes = 90
  static fallAsleepMinutes = 15

  calcBedtimes() {
    const wakeTimeValue = this.wakeTimeTarget.value
    if (!wakeTimeValue) {
      this.resultBedtimesTarget.textContent = "—"
      return
    }

    const [hours, minutes] = wakeTimeValue.split(":").map(Number)
    const wakeDate = new Date()
    wakeDate.setHours(hours, minutes, 0, 0)

    const cycles = [6, 5, 4, 3]
    const suggestions = cycles.map(numCycles => {
      const sleepMinutes = numCycles * this.constructor.cycleMinutes
      const totalMinutes = sleepMinutes + this.constructor.fallAsleepMinutes
      const bedtime = new Date(wakeDate.getTime() - totalMinutes * 60 * 1000)
      const sleepHours = (numCycles * this.constructor.cycleMinutes) / 60
      return this.fmtTime(bedtime) + " (" + numCycles + " cycles, " + this.fmt(sleepHours) + "h sleep)"
    })

    this.resultBedtimesTarget.innerHTML = suggestions.join("<br>")
  }

  calcWakeTimes() {
    const bedTimeValue = this.bedTimeTarget.value
    if (!bedTimeValue) {
      this.resultWakeTimesTarget.textContent = "—"
      return
    }

    const [hours, minutes] = bedTimeValue.split(":").map(Number)
    const bedDate = new Date()
    bedDate.setHours(hours, minutes, 0, 0)

    const fallAsleepDate = new Date(bedDate.getTime() + this.constructor.fallAsleepMinutes * 60 * 1000)

    const cycles = [3, 4, 5, 6]
    const suggestions = cycles.map(numCycles => {
      const sleepMinutes = numCycles * this.constructor.cycleMinutes
      const wakeTime = new Date(fallAsleepDate.getTime() + sleepMinutes * 60 * 1000)
      const sleepHours = (numCycles * this.constructor.cycleMinutes) / 60
      return this.fmtTime(wakeTime) + " (" + numCycles + " cycles, " + this.fmt(sleepHours) + "h sleep)"
    })

    this.resultWakeTimesTarget.innerHTML = suggestions.join("<br>")
  }

  fmtTime(date) {
    const h = date.getHours()
    const m = date.getMinutes()
    const period = h >= 12 ? "PM" : "AM"
    const displayH = h % 12 === 0 ? 12 : h % 12
    return displayH + ":" + String(m).padStart(2, "0") + " " + period
  }

  fmt(n) {
    return n.toFixed(1)
  }
}
