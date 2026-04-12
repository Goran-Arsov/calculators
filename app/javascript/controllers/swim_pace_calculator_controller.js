import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["distance", "timeMin", "timeSec", "poolUnit",
                     "pacePer100m", "pacePer100y", "speedPerHour",
                     "estimatedTimes"]

  static estimates = [
    { label: "50m", distance: 50, factor: 0.92 },
    { label: "100m", distance: 100, factor: 0.95 },
    { label: "200m", distance: 200, factor: 0.97 },
    { label: "400m", distance: 400, factor: 1.0 },
    { label: "800m", distance: 800, factor: 1.03 },
    { label: "1500m", distance: 1500, factor: 1.06 }
  ]

  calculate() {
    const distance = parseFloat(this.distanceTarget.value) || 0
    const min = parseInt(this.timeMinTarget.value) || 0
    const sec = parseInt(this.timeSecTarget.value) || 0
    const totalSec = min * 60 + sec
    const poolUnit = this.poolUnitTarget.value

    if (distance <= 0 || totalSec <= 0) {
      this.clearResults()
      return
    }

    let pacePer100m, pacePer100y
    const rawPace = (totalSec / distance) * 100

    if (poolUnit === "meters") {
      pacePer100m = rawPace
      pacePer100y = rawPace / 1.09361
    } else {
      pacePer100y = rawPace
      pacePer100m = rawPace * 1.09361
    }

    this.pacePer100mTarget.textContent = this.formatPace(pacePer100m)
    this.pacePer100yTarget.textContent = this.formatPace(pacePer100y)

    const speedPerHour = (distance / totalSec) * 3600
    this.speedPerHourTarget.textContent = `${speedPerHour.toFixed(0)} ${poolUnit}/h`

    // Build estimated times
    let html = ""
    for (const est of this.constructor.estimates) {
      const adjPace = pacePer100m * est.factor
      const estSec = (adjPace / 100) * est.distance
      html += `<div class="flex justify-between text-sm py-1.5 border-b border-gray-100 dark:border-gray-800">
        <span class="text-gray-600 dark:text-gray-400">${est.label}</span>
        <span class="font-semibold text-gray-800 dark:text-gray-200">${this.formatTime(estSec)}</span>
        <span class="text-gray-500 dark:text-gray-400 text-xs">${this.formatPace(adjPace)} /100m</span>
      </div>`
    }
    this.estimatedTimesTarget.innerHTML = html
  }

  formatPace(seconds) {
    const total = Math.round(seconds)
    const min = Math.floor(total / 60)
    const sec = total % 60
    return `${min}:${String(sec).padStart(2, "0")}`
  }

  formatTime(totalSec) {
    totalSec = Math.round(totalSec)
    const h = Math.floor(totalSec / 3600)
    const m = Math.floor((totalSec % 3600) / 60)
    const s = totalSec % 60
    if (h > 0) return `${h}:${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`
    return `${m}:${String(s).padStart(2, "0")}`
  }

  clearResults() {
    this.pacePer100mTarget.textContent = "\u2014"
    this.pacePer100yTarget.textContent = "\u2014"
    this.speedPerHourTarget.textContent = "\u2014"
    this.estimatedTimesTarget.innerHTML = ""
  }

  copy() {
    const text = [
      `Pace per 100m: ${this.pacePer100mTarget.textContent}`,
      `Pace per 100y: ${this.pacePer100yTarget.textContent}`,
      `Speed: ${this.speedPerHourTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
