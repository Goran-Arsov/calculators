import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "altitude", "baseTime", "canningMethod", "basePressure", "pressureFields",
    "results", "adjustedTime", "adjustedPressure", "extraMinutes", "extraPsi", "note"
  ]

  connect() {
    this.togglePressureFields()
  }

  togglePressureFields() {
    const method = this.canningMethodTarget.value
    const showPressure = method === "pressure_dial" || method === "pressure_weighted"
    this.pressureFieldsTarget.classList.toggle("hidden", !showPressure)
    this.calculate()
  }

  calculate() {
    const altitude = parseInt(this.altitudeTarget.value) || 0
    const baseTime = parseInt(this.baseTimeTarget.value) || 0
    const method = this.canningMethodTarget.value
    const basePressure = parseInt(this.basePressureTarget.value) || 10

    if (altitude < 0 || altitude > 10000 || baseTime <= 0 || !method) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    if (method === "water_bath") {
      this.calculateWaterBath(altitude, baseTime)
    } else if (method === "pressure_dial") {
      this.calculatePressureDial(altitude, baseTime, basePressure)
    } else if (method === "pressure_weighted") {
      this.calculatePressureWeighted(altitude, baseTime, basePressure)
    }

    this.resultsTarget.classList.remove("hidden")
  }

  calculateWaterBath(altitude, baseTime) {
    let extra = 0
    if (altitude > 8000) extra = 20
    else if (altitude > 6000) extra = 15
    else if (altitude > 3000) extra = 10
    else if (altitude > 1000) extra = 5

    this.adjustedTimeTarget.textContent = `${baseTime + extra} minutes`
    this.extraMinutesTarget.textContent = `+${extra} minutes`
    this.adjustedPressureTarget.textContent = "N/A (water bath)"
    this.extraPsiTarget.textContent = "N/A"
    this.noteTarget.textContent = extra === 0
      ? "No adjustment needed at your altitude."
      : `Add ${extra} minutes to processing time at ${altitude} ft altitude.`
  }

  calculatePressureDial(altitude, baseTime, basePressure) {
    let extraPsi = 0
    if (altitude > 8000) extraPsi = 5
    else if (altitude > 6000) extraPsi = 4
    else if (altitude > 4000) extraPsi = 3
    else if (altitude > 2000) extraPsi = 2
    else if (altitude > 1000) extraPsi = 1

    const adjustedPressure = basePressure + extraPsi

    this.adjustedTimeTarget.textContent = `${baseTime} minutes`
    this.extraMinutesTarget.textContent = "No change"
    this.adjustedPressureTarget.textContent = `${adjustedPressure} PSI`
    this.extraPsiTarget.textContent = `+${extraPsi} PSI`
    this.noteTarget.textContent = `Dial gauge: increase pressure by ${extraPsi} PSI at ${altitude} ft. Process at ${adjustedPressure} PSI for ${baseTime} minutes.`
  }

  calculatePressureWeighted(altitude, baseTime, basePressure) {
    const adjustedPressure = altitude > 1000 ? 15 : 10

    this.adjustedTimeTarget.textContent = `${baseTime} minutes`
    this.extraMinutesTarget.textContent = "No change"
    this.adjustedPressureTarget.textContent = `${adjustedPressure} PSI`
    this.extraPsiTarget.textContent = altitude > 1000 ? "Use 15 PSI" : "Use 10 PSI"
    this.noteTarget.textContent = `Weighted gauge: use ${adjustedPressure} PSI at ${altitude} ft. Process for ${baseTime} minutes.`
  }

  copy() {
    const text = [
      `Canning Altitude Adjustment:`,
      `Adjusted Time: ${this.adjustedTimeTarget.textContent}`,
      `Adjusted Pressure: ${this.adjustedPressureTarget.textContent}`,
      `Note: ${this.noteTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
