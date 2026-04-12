import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mode", "thresholdMin", "thresholdSec",
                     "raceDistance", "raceTimeH", "raceTimeM", "raceTimeS",
                     "thresholdFields", "raceFields",
                     "thresholdPace",
                     "zone1", "zone2", "zone3", "zone4", "zone5"]

  static zones = [
    { name: "Zone 1 \u2013 Easy / Recovery", minPct: 125, maxPct: 140 },
    { name: "Zone 2 \u2013 Aerobic / Endurance", minPct: 110, maxPct: 125 },
    { name: "Zone 3 \u2013 Tempo / Threshold", minPct: 97, maxPct: 110 },
    { name: "Zone 4 \u2013 VO2max / Interval", minPct: 88, maxPct: 97 },
    { name: "Zone 5 \u2013 Speed / Repetition", minPct: 78, maxPct: 88 }
  ]

  static raceFactors = { "5k": 1.06, "10k": 1.02, "half_marathon": 0.96, "marathon": 0.89 }
  static raceDistances = { "5k": 5.0, "10k": 10.0, "half_marathon": 21.0975, "marathon": 42.195 }

  connect() {
    this.toggleMode()
  }

  toggleMode() {
    const mode = this.modeTarget.value
    this.thresholdFieldsTarget.classList.toggle("hidden", mode !== "threshold")
    this.raceFieldsTarget.classList.toggle("hidden", mode !== "race")
    this.calculate()
  }

  calculate() {
    const mode = this.modeTarget.value
    let thresholdPace

    if (mode === "threshold") {
      const min = parseInt(this.thresholdMinTarget.value) || 0
      const sec = parseInt(this.thresholdSecTarget.value) || 0
      thresholdPace = min * 60 + sec
      if (thresholdPace <= 0) { this.clearResults(); return }
    } else {
      const h = parseInt(this.raceTimeHTarget.value) || 0
      const m = parseInt(this.raceTimeMTarget.value) || 0
      const s = parseInt(this.raceTimeSTarget.value) || 0
      const totalSec = h * 3600 + m * 60 + s
      const dist = this.raceDistanceTarget.value
      const distKm = this.constructor.raceDistances[dist]
      if (totalSec <= 0 || !distKm) { this.clearResults(); return }
      const racePace = totalSec / distKm
      const factor = this.constructor.raceFactors[dist] || 1.0
      thresholdPace = racePace * factor
    }

    this.thresholdPaceTarget.textContent = this.formatPace(thresholdPace)

    const zoneTargets = [this.zone1Target, this.zone2Target, this.zone3Target, this.zone4Target, this.zone5Target]
    this.constructor.zones.forEach((zone, i) => {
      const minPace = Math.round(thresholdPace * zone.minPct / 100)
      const maxPace = Math.round(thresholdPace * zone.maxPct / 100)
      const fast = Math.min(minPace, maxPace)
      const slow = Math.max(minPace, maxPace)
      zoneTargets[i].textContent = `${this.formatPace(fast)} \u2013 ${this.formatPace(slow)}`
    })
  }

  formatPace(secondsPerKm) {
    const total = Math.round(secondsPerKm)
    const min = Math.floor(total / 60)
    const sec = total % 60
    return `${min}:${String(sec).padStart(2, "0")} /km`
  }

  clearResults() {
    this.thresholdPaceTarget.textContent = "\u2014"
    const zoneTargets = [this.zone1Target, this.zone2Target, this.zone3Target, this.zone4Target, this.zone5Target]
    zoneTargets.forEach(t => t.textContent = "\u2014")
  }

  copy() {
    const zones = this.constructor.zones
    const zoneTargets = [this.zone1Target, this.zone2Target, this.zone3Target, this.zone4Target, this.zone5Target]
    const text = [
      `Threshold Pace: ${this.thresholdPaceTarget.textContent}`,
      ...zones.map((z, i) => `${z.name}: ${zoneTargets[i].textContent}`)
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
