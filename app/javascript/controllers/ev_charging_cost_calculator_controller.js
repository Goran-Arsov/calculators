import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "batteryCapacity", "currentCharge", "targetCharge",
    "electricityRate", "chargerType", "chargerEfficiency",
    "energyNeeded", "energyFromGrid", "chargingCost", "chargeTime",
    "costPerMile", "milesAdded", "monthlyCost"
  ]

  calculate() {
    const battery = parseFloat(this.batteryCapacityTarget.value) || 0
    const currentPct = (parseFloat(this.currentChargeTarget.value) || 0) / 100
    const targetPct = (parseFloat(this.targetChargeTarget.value) || 80) / 100
    const rate = parseFloat(this.electricityRateTarget.value) || 0
    const chargerType = this.chargerTypeTarget.value
    const efficiency = (parseFloat(this.chargerEfficiencyTarget.value) || 90) / 100

    if (battery <= 0 || rate <= 0 || targetPct <= currentPct || efficiency <= 0) {
      this.clearResults()
      return
    }

    const energyNeeded = battery * (targetPct - currentPct)
    const energyFromGrid = energyNeeded / efficiency
    const cost = energyFromGrid * rate

    const power = { level1: 1.4, level2: 7.2, dc_fast: 150, supercharger: 250 }[chargerType] || 7.2
    const chargeTimeHrs = energyFromGrid / power

    const milesPerKwh = 3.5
    const milesAdded = energyNeeded * milesPerKwh
    const costPerMile = milesAdded > 0 ? cost / milesAdded : 0

    // Monthly estimate based on 40 mile daily commute
    const dailyKwh = 40 / milesPerKwh / efficiency
    const monthlyCost = dailyKwh * rate * 30

    this.energyNeededTarget.textContent = energyNeeded.toFixed(2) + " kWh"
    this.energyFromGridTarget.textContent = energyFromGrid.toFixed(2) + " kWh"
    this.chargingCostTarget.textContent = "$" + cost.toFixed(2)
    this.costPerMileTarget.textContent = "$" + costPerMile.toFixed(3)
    this.milesAddedTarget.textContent = milesAdded.toFixed(1) + " mi"
    this.monthlyCostTarget.textContent = "$" + monthlyCost.toFixed(2)

    if (chargeTimeHrs < 1) {
      this.chargeTimeTarget.textContent = Math.round(chargeTimeHrs * 60) + " min"
    } else {
      this.chargeTimeTarget.textContent = chargeTimeHrs.toFixed(1) + " hrs"
    }
  }

  clearResults() {
    this.energyNeededTarget.textContent = "0.00 kWh"
    this.energyFromGridTarget.textContent = "0.00 kWh"
    this.chargingCostTarget.textContent = "$0.00"
    this.chargeTimeTarget.textContent = "0 min"
    this.costPerMileTarget.textContent = "$0.000"
    this.milesAddedTarget.textContent = "0.0 mi"
    this.monthlyCostTarget.textContent = "$0.00"
  }

  copy() {
    const text = `Energy Needed: ${this.energyNeededTarget.textContent}\nCharging Cost: ${this.chargingCostTarget.textContent}\nCharge Time: ${this.chargeTimeTarget.textContent}\nCost per Mile: ${this.costPerMileTarget.textContent}\nMonthly Estimate: ${this.monthlyCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
