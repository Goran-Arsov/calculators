import { Controller } from "@hotwired/stimulus"
import { MI_TO_KM } from "utils/units"

export default class extends Controller {
  static targets = ["mode", "thresholdMin", "thresholdSec",
                     "raceDistance", "raceTimeH", "raceTimeM", "raceTimeS",
                     "thresholdFields", "raceFields",
                     "thresholdPace",
                     "unitSystem", "thresholdLabel",
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
    this.updateLabels()
    this.toggleMode()
  }

  toggleMode() {
    const mode = this.modeTarget.value
    this.thresholdFieldsTarget.classList.toggle("hidden", mode !== "threshold")
    this.raceFieldsTarget.classList.toggle("hidden", mode !== "race")
    this.calculate()
  }

  switchUnits() {
    const toImperial = this.unitSystemTarget.value === "imperial"
    // Convert the threshold pace input between /km and /mi so the displayed
    // value stays consistent after the unit switch. Race time does not need
    // conversion (it's h/m/s for a fixed race distance).
    const min = parseInt(this.thresholdMinTarget.value) || 0
    const sec = parseInt(this.thresholdSecTarget.value) || 0
    const totalSec = min * 60 + sec
    if (totalSec > 0) {
      // If switching to imperial, the current input was /km -> convert to /mi.
      // If switching to metric, the current input was /mi -> convert to /km.
      const converted = toImperial ? totalSec * MI_TO_KM : totalSec / MI_TO_KM
      const newMin = Math.floor(converted / 60)
      const newSec = Math.round(converted % 60)
      this.thresholdMinTarget.value = newMin
      this.thresholdSecTarget.value = String(newSec).padStart(2, "0")
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const imperial = this.unitSystemTarget.value === "imperial"
    this.thresholdLabelTarget.textContent = imperial ? "Threshold Pace (/mi)" : "Threshold Pace (/km)"
  }

  calculate() {
    const mode = this.modeTarget.value
    const imperial = this.unitSystemTarget.value === "imperial"
    let thresholdPacePerKm

    if (mode === "threshold") {
      const min = parseInt(this.thresholdMinTarget.value) || 0
      const sec = parseInt(this.thresholdSecTarget.value) || 0
      const inputPaceSec = min * 60 + sec
      if (inputPaceSec <= 0) { this.clearResults(); return }
      // Convert to sec/km if user is entering min/mi.
      thresholdPacePerKm = imperial ? inputPaceSec / MI_TO_KM : inputPaceSec
    } else {
      const h = parseInt(this.raceTimeHTarget.value) || 0
      const m = parseInt(this.raceTimeMTarget.value) || 0
      const s = parseInt(this.raceTimeSTarget.value) || 0
      const totalSec = h * 3600 + m * 60 + s
      const dist = this.raceDistanceTarget.value
      const distKm = this.constructor.raceDistances[dist]
      if (totalSec <= 0 || !distKm) { this.clearResults(); return }
      const racePacePerKm = totalSec / distKm
      const factor = this.constructor.raceFactors[dist] || 1.0
      thresholdPacePerKm = racePacePerKm * factor
    }

    this.thresholdPaceTarget.textContent = this.formatPace(thresholdPacePerKm, imperial)

    const zoneTargets = [this.zone1Target, this.zone2Target, this.zone3Target, this.zone4Target, this.zone5Target]
    this.constructor.zones.forEach((zone, i) => {
      const minPace = Math.round(thresholdPacePerKm * zone.minPct / 100)
      const maxPace = Math.round(thresholdPacePerKm * zone.maxPct / 100)
      const fast = Math.min(minPace, maxPace)
      const slow = Math.max(minPace, maxPace)
      zoneTargets[i].textContent = `${this.formatPace(fast, imperial)} \u2013 ${this.formatPace(slow, imperial)}`
    })
  }

  formatPace(secondsPerKm, imperial) {
    const secondsPerUnit = imperial ? secondsPerKm * MI_TO_KM : secondsPerKm
    const total = Math.round(secondsPerUnit)
    const min = Math.floor(total / 60)
    const sec = total % 60
    const suffix = imperial ? "/mi" : "/km"
    return `${min}:${String(sec).padStart(2, "0")} ${suffix}`
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
