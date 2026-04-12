import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mode", "ftpDirect", "testPower", "weight", "weightUnit",
                     "directFields", "testFields",
                     "ftp", "wattsPerKg", "riderCategory",
                     "zone1", "zone2", "zone3", "zone4", "zone5", "zone6", "zone7"]

  static zones = [
    { name: "Zone 1 \u2013 Active Recovery", minPct: 0, maxPct: 55 },
    { name: "Zone 2 \u2013 Endurance", minPct: 56, maxPct: 75 },
    { name: "Zone 3 \u2013 Tempo", minPct: 76, maxPct: 90 },
    { name: "Zone 4 \u2013 Threshold", minPct: 91, maxPct: 105 },
    { name: "Zone 5 \u2013 VO2max", minPct: 106, maxPct: 120 },
    { name: "Zone 6 \u2013 Anaerobic", minPct: 121, maxPct: 150 },
    { name: "Zone 7 \u2013 Neuromuscular", minPct: 151, maxPct: null }
  ]

  static factors = { direct: 1.0, twenty_minute: 0.95, eight_minute: 0.90, ramp: 0.75 }

  connect() {
    this.toggleMode()
  }

  toggleMode() {
    const mode = this.modeTarget.value
    this.directFieldsTarget.classList.toggle("hidden", mode !== "direct")
    this.testFieldsTarget.classList.toggle("hidden", mode === "direct")
    this.calculate()
  }

  calculate() {
    const mode = this.modeTarget.value
    let ftp

    if (mode === "direct") {
      ftp = parseFloat(this.ftpDirectTarget.value) || 0
    } else {
      const testPower = parseFloat(this.testPowerTarget.value) || 0
      if (testPower <= 0) { this.clearResults(); return }
      const factor = this.constructor.factors[mode] || 1.0
      ftp = testPower * factor
    }

    if (ftp <= 0) { this.clearResults(); return }

    this.ftpTarget.textContent = `${Math.round(ftp)} W`

    const weight = parseFloat(this.weightTarget.value) || 0
    const weightUnit = this.weightUnitTarget.value
    if (weight > 0) {
      const weightKg = weightUnit === "lbs" ? weight * 0.453592 : weight
      const wpk = ftp / weightKg
      this.wattsPerKgTarget.textContent = `${wpk.toFixed(2)} W/kg`
      this.riderCategoryTarget.textContent = this.riderCategory(wpk)
    } else {
      this.wattsPerKgTarget.textContent = "\u2014"
      this.riderCategoryTarget.textContent = "\u2014"
    }

    const zoneTargets = [this.zone1Target, this.zone2Target, this.zone3Target, this.zone4Target, this.zone5Target, this.zone6Target, this.zone7Target]
    this.constructor.zones.forEach((zone, i) => {
      const minW = Math.round(ftp * zone.minPct / 100)
      const maxW = zone.maxPct ? Math.round(ftp * zone.maxPct / 100) : null
      zoneTargets[i].textContent = maxW ? `${minW} \u2013 ${maxW} W` : `${minW}+ W`
    })
  }

  riderCategory(wpk) {
    if (wpk >= 5.5) return "World Tour Pro"
    if (wpk >= 4.6) return "Cat 1 / Elite"
    if (wpk >= 4.0) return "Cat 2 / Very Strong"
    if (wpk >= 3.4) return "Cat 3 / Strong"
    if (wpk >= 2.8) return "Cat 4 / Moderate"
    if (wpk >= 2.0) return "Cat 5 / Recreational"
    return "Beginner"
  }

  clearResults() {
    this.ftpTarget.textContent = "\u2014"
    this.wattsPerKgTarget.textContent = "\u2014"
    this.riderCategoryTarget.textContent = "\u2014"
    const zoneTargets = [this.zone1Target, this.zone2Target, this.zone3Target, this.zone4Target, this.zone5Target, this.zone6Target, this.zone7Target]
    zoneTargets.forEach(t => t.textContent = "\u2014")
  }

  copy() {
    const zones = this.constructor.zones
    const zoneTargets = [this.zone1Target, this.zone2Target, this.zone3Target, this.zone4Target, this.zone5Target, this.zone6Target, this.zone7Target]
    const text = [
      `FTP: ${this.ftpTarget.textContent}`,
      `W/kg: ${this.wattsPerKgTarget.textContent}`,
      `Category: ${this.riderCategoryTarget.textContent}`,
      ...zones.map((z, i) => `${z.name}: ${zoneTargets[i].textContent}`)
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
