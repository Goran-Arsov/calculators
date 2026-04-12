import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["decibelLevel", "exposureHours",
                     "nioshSafe", "nioshDose", "oshaSafe", "oshaDose",
                     "riskLevel", "comparison"]

  static NIOSH_BASE_DB = 85
  static NIOSH_BASE_HOURS = 8.0
  static NIOSH_EXCHANGE = 3
  static OSHA_BASE_DB = 90
  static OSHA_BASE_HOURS = 8.0
  static OSHA_EXCHANGE = 5

  calculate() {
    const db = parseFloat(this.decibelLevelTarget.value) || 0
    const exposureHours = parseFloat(this.exposureHoursTarget.value) || 0

    if (db <= 0) {
      this.clearResults()
      return
    }

    const nioshSafe = this.safeTime(db, this.constructor.NIOSH_BASE_DB, this.constructor.NIOSH_BASE_HOURS, this.constructor.NIOSH_EXCHANGE)
    const oshaSafe = this.safeTime(db, this.constructor.OSHA_BASE_DB, this.constructor.OSHA_BASE_HOURS, this.constructor.OSHA_EXCHANGE)

    this.nioshSafeTarget.textContent = this.formatDuration(nioshSafe)
    this.oshaSafeTarget.textContent = this.formatDuration(oshaSafe)

    if (exposureHours > 0) {
      const nioshDose = (exposureHours / nioshSafe * 100)
      const oshaDose = (exposureHours / oshaSafe * 100)
      this.nioshDoseTarget.textContent = `${nioshDose.toFixed(1)}%`
      this.nioshDoseTarget.className = nioshDose > 100 ? "text-lg font-bold text-red-600 dark:text-red-400" : "text-lg font-bold text-green-600 dark:text-green-400"
      this.oshaDoseTarget.textContent = `${oshaDose.toFixed(1)}%`
      this.oshaDoseTarget.className = oshaDose > 100 ? "text-lg font-bold text-red-600 dark:text-red-400" : "text-lg font-bold text-green-600 dark:text-green-400"
    } else {
      this.nioshDoseTarget.textContent = "—"
      this.nioshDoseTarget.className = "text-lg font-bold text-gray-600 dark:text-gray-400"
      this.oshaDoseTarget.textContent = "—"
      this.oshaDoseTarget.className = "text-lg font-bold text-gray-600 dark:text-gray-400"
    }

    this.riskLevelTarget.textContent = this.riskLevel(db)
    this.riskLevelTarget.className = this.riskClass(db)

    this.buildComparison(db)
  }

  safeTime(db, baseDb, baseHours, exchangeRate) {
    if (db < baseDb) return Infinity
    return baseHours / Math.pow(2, (db - baseDb) / exchangeRate)
  }

  formatDuration(hours) {
    if (hours === Infinity) return "Unlimited"
    if (hours < 1 / 3600) return "< 1 second"
    if (hours >= 1) {
      const h = Math.floor(hours)
      const m = Math.round((hours - h) * 60)
      return m > 0 ? `${h}h ${m}m` : `${h}h`
    }
    if (hours * 60 >= 1) {
      const m = Math.floor(hours * 60)
      const s = Math.round((hours * 60 - m) * 60)
      return s > 0 ? `${m}m ${s}s` : `${m}m`
    }
    return `${Math.round(hours * 3600)}s`
  }

  riskLevel(db) {
    if (db < 70) return "Safe - No hearing damage risk"
    if (db < 85) return "Low - Prolonged exposure may cause gradual damage"
    if (db < 100) return "Moderate - Hearing protection recommended"
    if (db < 120) return "High - Hearing protection required"
    return "Extreme - Immediate hearing damage possible"
  }

  riskClass(db) {
    const base = "text-sm font-semibold"
    if (db < 70) return `${base} text-green-600 dark:text-green-400`
    if (db < 85) return `${base} text-lime-600 dark:text-lime-400`
    if (db < 100) return `${base} text-yellow-600 dark:text-yellow-400`
    if (db < 120) return `${base} text-orange-600 dark:text-orange-400`
    return `${base} text-red-600 dark:text-red-400`
  }

  buildComparison(db) {
    const refs = [
      { name: "Whisper", db: 30 },
      { name: "Normal conversation", db: 60 },
      { name: "Vacuum cleaner", db: 70 },
      { name: "City traffic", db: 80 },
      { name: "Lawn mower", db: 85 },
      { name: "Motorcycle", db: 95 },
      { name: "Concert", db: 105 },
      { name: "Chainsaw", db: 110 },
      { name: "Ambulance siren", db: 120 },
      { name: "Fireworks", db: 140 }
    ]
    let html = ""
    for (const ref of refs) {
      const isActive = Math.abs(db - ref.db) <= 5
      const cls = isActive ? "bg-yellow-100 dark:bg-yellow-900/30 font-semibold" : ""
      html += `<div class="flex justify-between text-sm py-1 px-2 rounded ${cls}">
        <span class="text-gray-600 dark:text-gray-400">${ref.name}</span>
        <span class="font-mono text-gray-700 dark:text-gray-300">${ref.db} dB</span>
      </div>`
    }
    this.comparisonTarget.innerHTML = html
  }

  clearResults() {
    this.nioshSafeTarget.textContent = "—"
    this.oshaSafeTarget.textContent = "—"
    this.nioshDoseTarget.textContent = "—"
    this.oshaDoseTarget.textContent = "—"
    this.riskLevelTarget.textContent = "—"
    this.comparisonTarget.innerHTML = ""
  }

  copy() {
    const text = [
      `Decibel Level: ${this.decibelLevelTarget.value} dB`,
      `NIOSH Safe Exposure: ${this.nioshSafeTarget.textContent}`,
      `OSHA Safe Exposure: ${this.oshaSafeTarget.textContent}`,
      `NIOSH Dose: ${this.nioshDoseTarget.textContent}`,
      `OSHA Dose: ${this.oshaDoseTarget.textContent}`,
      `Risk Level: ${this.riskLevelTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
