import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "activityLevel",
                     "forageLbs", "grainLbs", "totalFeedLbs",
                     "dailyEnergyMcal", "saltOz", "mineralOz",
                     "waterGallons", "forageRatio"]

  static foragePercentages = {
    maintenance: 0.015, light: 0.018, moderate: 0.020, heavy: 0.020, intense: 0.020
  }

  static grainPercentages = {
    maintenance: 0.0, light: 0.003, moderate: 0.005, heavy: 0.008, intense: 0.012
  }

  static energyRequirements = {
    maintenance: 0.0333, light: 0.0400, moderate: 0.0467, heavy: 0.0533, intense: 0.0600
  }

  calculate() {
    const weightLbs = parseFloat(this.weightTarget.value) || 0
    const activityLevel = this.activityLevelTarget.value

    if (weightLbs <= 0) {
      this.clearResults()
      return
    }

    const weightKg = weightLbs * 0.453592
    const forageLbs = weightLbs * (this.constructor.foragePercentages[activityLevel] || 0.015)
    const grainLbs = weightLbs * (this.constructor.grainPercentages[activityLevel] || 0.0)
    const totalFeedLbs = forageLbs + grainLbs
    const dailyEnergy = weightKg * (this.constructor.energyRequirements[activityLevel] || 0.0333)

    const weightRatio = weightLbs / 1000.0
    const saltOz = 1.5 * weightRatio
    const mineralOz = 1.5 * weightRatio

    const waterMin = (weightLbs / 100.0) * 0.5
    const waterMax = (weightLbs / 100.0) * 1.0
    const forageRatio = totalFeedLbs > 0 ? (forageLbs / totalFeedLbs * 100) : 100

    this.forageLbsTarget.textContent = `${forageLbs.toFixed(1)} lbs`
    this.grainLbsTarget.textContent = `${grainLbs.toFixed(1)} lbs`
    this.totalFeedLbsTarget.textContent = `${totalFeedLbs.toFixed(1)} lbs`
    this.dailyEnergyMcalTarget.textContent = `${dailyEnergy.toFixed(1)} Mcal`
    this.saltOzTarget.textContent = `${saltOz.toFixed(1)} oz`
    this.mineralOzTarget.textContent = `${mineralOz.toFixed(1)} oz`
    this.waterGallonsTarget.textContent = `${waterMin.toFixed(1)}-${waterMax.toFixed(1)} gal`
    this.forageRatioTarget.textContent = `${Math.round(forageRatio)}%`
  }

  clearResults() {
    const targets = ["forageLbs", "grainLbs", "totalFeedLbs", "dailyEnergyMcal",
                     "saltOz", "mineralOz", "waterGallons", "forageRatio"]
    targets.forEach(t => this[`${t}Target`].textContent = "\u2014")
  }

  copy() {
    const text = [
      `Forage (Hay): ${this.forageLbsTarget.textContent}`,
      `Grain: ${this.grainLbsTarget.textContent}`,
      `Total Feed: ${this.totalFeedLbsTarget.textContent}`,
      `Daily Energy: ${this.dailyEnergyMcalTarget.textContent}`,
      `Salt: ${this.saltOzTarget.textContent}`,
      `Mineral Supplement: ${this.mineralOzTarget.textContent}`,
      `Water: ${this.waterGallonsTarget.textContent}`,
      `Forage Ratio: ${this.forageRatioTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
