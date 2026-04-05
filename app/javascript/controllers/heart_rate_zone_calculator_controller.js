import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["age", "restingHr", "maxHr", "hrr",
                     "zone1", "zone2", "zone3", "zone4", "zone5"]

  static zones = [
    { name: "Zone 1 – Warm Up / Recovery", minPct: 50, maxPct: 60 },
    { name: "Zone 2 – Fat Burn", minPct: 60, maxPct: 70 },
    { name: "Zone 3 – Aerobic / Cardio", minPct: 70, maxPct: 80 },
    { name: "Zone 4 – Anaerobic / Threshold", minPct: 80, maxPct: 90 },
    { name: "Zone 5 – VO2 Max / Peak", minPct: 90, maxPct: 100 }
  ]

  calculate() {
    const age = parseInt(this.ageTarget.value) || 0
    const restingHr = parseInt(this.restingHrTarget.value) || 0

    if (age <= 0 || restingHr <= 0) {
      this.clearResults()
      return
    }

    // Tanaka formula: HRmax = 208 - 0.7 * age
    const maxHr = Math.round(208 - 0.7 * age)
    const hrr = maxHr - restingHr

    if (hrr <= 0) {
      this.clearResults()
      return
    }

    this.maxHrTarget.textContent = `${maxHr} bpm`
    this.hrrTarget.textContent = `${hrr} bpm`

    const zoneTargets = [this.zone1Target, this.zone2Target, this.zone3Target, this.zone4Target, this.zone5Target]

    this.constructor.zones.forEach((zone, i) => {
      const minBpm = Math.round(restingHr + hrr * zone.minPct / 100)
      const maxBpm = Math.round(restingHr + hrr * zone.maxPct / 100)
      zoneTargets[i].textContent = `${minBpm} – ${maxBpm} bpm`
    })
  }

  clearResults() {
    this.maxHrTarget.textContent = "—"
    this.hrrTarget.textContent = "—"
    const zoneTargets = [this.zone1Target, this.zone2Target, this.zone3Target, this.zone4Target, this.zone5Target]
    zoneTargets.forEach(t => t.textContent = "—")
  }

  copy() {
    const zones = this.constructor.zones
    const zoneTargets = [this.zone1Target, this.zone2Target, this.zone3Target, this.zone4Target, this.zone5Target]
    const text = [
      `Max Heart Rate: ${this.maxHrTarget.textContent}`,
      `Heart Rate Reserve: ${this.hrrTarget.textContent}`,
      ...zones.map((z, i) => `${z.name}: ${zoneTargets[i].textContent}`)
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
