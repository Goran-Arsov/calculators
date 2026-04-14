import { Controller } from "@hotwired/stimulus"
import { LB_TO_KG, OZ_TO_G, GAL_TO_L } from "utils/units"

export default class extends Controller {
  static targets = ["weight", "activityLevel",
                     "forageLbs", "grainLbs", "totalFeedLbs",
                     "dailyEnergyMcal", "saltOz", "mineralOz",
                     "waterGallons", "forageRatio",
                     "unitSystem", "weightLabel", "saltLabel", "mineralLabel"]

  static foragePercentages = {
    maintenance: 0.015, light: 0.018, moderate: 0.020, heavy: 0.020, intense: 0.020
  }

  static grainPercentages = {
    maintenance: 0.0, light: 0.003, moderate: 0.005, heavy: 0.008, intense: 0.012
  }

  static energyRequirements = {
    maintenance: 0.0333, light: 0.0400, moderate: 0.0467, heavy: 0.0533, intense: 0.0600
  }

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const n = parseFloat(this.weightTarget.value)
    if (Number.isFinite(n)) {
      this.weightTarget.value = (toMetric ? n * LB_TO_KG : n / LB_TO_KG).toFixed(1)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.weightLabelTarget.textContent = metric ? "Horse's Weight (kg)" : "Horse's Weight (lbs)"
    this.saltLabelTarget.textContent = metric ? "Salt (g)" : "Salt (oz)"
    this.mineralLabelTarget.textContent = metric ? "Mineral Supplement (g)" : "Mineral Supplement (oz)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const weightInput = parseFloat(this.weightTarget.value) || 0
    const activityLevel = this.activityLevelTarget.value

    if (weightInput <= 0) {
      this.clearResults()
      return
    }

    const weightLbs = metric ? weightInput / LB_TO_KG : weightInput
    const weightKg = weightLbs * LB_TO_KG
    const forageLbs = weightLbs * (this.constructor.foragePercentages[activityLevel] || 0.015)
    const grainLbs = weightLbs * (this.constructor.grainPercentages[activityLevel] || 0.0)
    const totalFeedLbs = forageLbs + grainLbs
    const dailyEnergy = weightKg * (this.constructor.energyRequirements[activityLevel] || 0.0333)

    const weightRatio = weightLbs / 1000.0
    const saltOz = 1.5 * weightRatio
    const mineralOz = 1.5 * weightRatio

    const waterMinGal = (weightLbs / 100.0) * 0.5
    const waterMaxGal = (weightLbs / 100.0) * 1.0
    const forageRatio = totalFeedLbs > 0 ? (forageLbs / totalFeedLbs * 100) : 100

    if (metric) {
      const forageKg = forageLbs * LB_TO_KG
      const grainKg = grainLbs * LB_TO_KG
      const totalKg = totalFeedLbs * LB_TO_KG
      const saltG = saltOz * OZ_TO_G
      const mineralG = mineralOz * OZ_TO_G
      const waterMinL = waterMinGal * GAL_TO_L
      const waterMaxL = waterMaxGal * GAL_TO_L
      this.forageLbsTarget.textContent = `${forageKg.toFixed(1)} kg`
      this.grainLbsTarget.textContent = `${grainKg.toFixed(1)} kg`
      this.totalFeedLbsTarget.textContent = `${totalKg.toFixed(1)} kg`
      this.saltOzTarget.textContent = `${saltG.toFixed(0)} g`
      this.mineralOzTarget.textContent = `${mineralG.toFixed(0)} g`
      this.waterGallonsTarget.textContent = `${waterMinL.toFixed(1)}-${waterMaxL.toFixed(1)} L`
    } else {
      this.forageLbsTarget.textContent = `${forageLbs.toFixed(1)} lbs`
      this.grainLbsTarget.textContent = `${grainLbs.toFixed(1)} lbs`
      this.totalFeedLbsTarget.textContent = `${totalFeedLbs.toFixed(1)} lbs`
      this.saltOzTarget.textContent = `${saltOz.toFixed(1)} oz`
      this.mineralOzTarget.textContent = `${mineralOz.toFixed(1)} oz`
      this.waterGallonsTarget.textContent = `${waterMinGal.toFixed(1)}-${waterMaxGal.toFixed(1)} gal`
    }
    this.dailyEnergyMcalTarget.textContent = `${dailyEnergy.toFixed(1)} Mcal`
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
      `${this.saltLabelTarget.textContent}: ${this.saltOzTarget.textContent}`,
      `${this.mineralLabelTarget.textContent}: ${this.mineralOzTarget.textContent}`,
      `Water: ${this.waterGallonsTarget.textContent}`,
      `Forage Ratio: ${this.forageRatioTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
