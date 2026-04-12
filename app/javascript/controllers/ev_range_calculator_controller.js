import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "batteryCapacity", "efficiency", "speed", "temperature", "hvac", "cargoWeight",
    "baseRange", "adjustedRange", "adjustedEfficiency", "rangeLoss",
    "level2Time", "dcFastTime"
  ]

  calculate() {
    const battery = parseFloat(this.batteryCapacityTarget.value) || 0
    const eff = parseFloat(this.efficiencyTarget.value) || 250
    const speed = parseFloat(this.speedTarget.value) || 65
    const temp = parseFloat(this.temperatureTarget.value) || 70
    const hvac = this.hvacTarget.checked
    const cargo = parseFloat(this.cargoWeightTarget.value) || 0

    if (battery <= 0 || eff <= 0 || speed <= 0) {
      this.clearResults()
      return
    }

    const baseRange = (battery * 1000) / eff

    // Speed factor
    let speedFactor = 1.0
    if (speed > 55 && speed <= 75) {
      speedFactor = 1.0 - ((speed - 55) * 0.012)
    } else if (speed > 75) {
      speedFactor = 1.0 - (20 * 0.012) - ((speed - 75) * 0.018)
    }

    // Temperature factor
    let tempFactor = 1.0
    if (temp < 60) {
      tempFactor = 1.0 - Math.min((60 - temp) * 0.005, 0.40)
    } else if (temp > 80) {
      tempFactor = 1.0 - Math.min((temp - 80) * 0.003, 0.15)
    }

    const hvacFactor = hvac ? 0.90 : 1.0
    let cargoFactor = 1.0 - (cargo / 100 * 0.01)
    cargoFactor = Math.max(cargoFactor, 0.70)

    const adjustedRange = baseRange * speedFactor * tempFactor * hvacFactor * cargoFactor
    const adjustedEff = (battery * 1000) / adjustedRange
    const rangeLoss = ((1 - adjustedRange / baseRange) * 100)

    const level2Hours = battery / 7.2
    const dcFastMin = (battery * 0.8 / 150) * 60

    this.baseRangeTarget.textContent = baseRange.toFixed(1) + " mi"
    this.adjustedRangeTarget.textContent = adjustedRange.toFixed(1) + " mi"
    this.adjustedEfficiencyTarget.textContent = adjustedEff.toFixed(0) + " Wh/mi"
    this.rangeLossTarget.textContent = rangeLoss.toFixed(1) + "%"
    this.level2TimeTarget.textContent = level2Hours.toFixed(1) + " hrs"
    this.dcFastTimeTarget.textContent = Math.round(dcFastMin) + " min"
  }

  clearResults() {
    this.baseRangeTarget.textContent = "0.0 mi"
    this.adjustedRangeTarget.textContent = "0.0 mi"
    this.adjustedEfficiencyTarget.textContent = "0 Wh/mi"
    this.rangeLossTarget.textContent = "0.0%"
    this.level2TimeTarget.textContent = "0.0 hrs"
    this.dcFastTimeTarget.textContent = "0 min"
  }

  copy() {
    const text = `Base Range: ${this.baseRangeTarget.textContent}\nAdjusted Range: ${this.adjustedRangeTarget.textContent}\nEfficiency: ${this.adjustedEfficiencyTarget.textContent}\nRange Loss: ${this.rangeLossTarget.textContent}\nLevel 2 Charge: ${this.level2TimeTarget.textContent}\nDC Fast Charge: ${this.dcFastTimeTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
