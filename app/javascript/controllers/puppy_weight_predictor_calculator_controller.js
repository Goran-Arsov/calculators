import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["currentWeight", "ageWeeks", "breedSize",
                     "predictedWeight", "predictedWeightKg", "growthPercentage",
                     "remainingGrowth", "weeksToAdult", "breedRange"]

  static growthCurves = {
    toy:    { 8: 0.47, 12: 0.60, 16: 0.72, 20: 0.82, 24: 0.90, 32: 0.95, 40: 0.98, 52: 1.0 },
    small:  { 8: 0.42, 12: 0.55, 16: 0.67, 20: 0.77, 24: 0.85, 32: 0.92, 40: 0.97, 52: 1.0 },
    medium: { 8: 0.33, 12: 0.45, 16: 0.55, 20: 0.65, 24: 0.75, 32: 0.85, 40: 0.92, 52: 0.97, 65: 1.0 },
    large:  { 8: 0.25, 12: 0.35, 16: 0.45, 20: 0.52, 24: 0.60, 32: 0.72, 40: 0.82, 52: 0.90, 65: 0.95, 78: 1.0 },
    giant:  { 8: 0.20, 12: 0.28, 16: 0.37, 20: 0.44, 24: 0.50, 32: 0.60, 40: 0.70, 52: 0.80, 65: 0.88, 78: 0.95, 104: 1.0 }
  }

  static breedWeightRanges = {
    toy:    { min: 4, max: 10 },
    small:  { min: 10, max: 25 },
    medium: { min: 25, max: 55 },
    large:  { min: 55, max: 90 },
    giant:  { min: 90, max: 200 }
  }

  calculate() {
    const weight = parseFloat(this.currentWeightTarget.value) || 0
    const ageWeeks = parseInt(this.ageWeeksTarget.value) || 0
    const breedSize = this.breedSizeTarget.value

    if (weight <= 0 || ageWeeks < 4) {
      this.clearResults()
      return
    }

    const curve = this.constructor.growthCurves[breedSize]
    const range = this.constructor.breedWeightRanges[breedSize]
    if (!curve || !range) {
      this.clearResults()
      return
    }

    const growthPct = this.interpolate(curve, ageWeeks)
    let predictedWeight = weight / growthPct
    predictedWeight = Math.max(range.min, Math.min(predictedWeight, range.max * 1.2))
    const predictedWeightKg = predictedWeight * 0.453592
    const remainingGrowthPct = (1 - growthPct) * 100

    const weeks = Object.keys(curve).map(Number).sort((a, b) => a - b)
    const adultWeek = weeks.find(w => curve[w] >= 1.0) || weeks[weeks.length - 1]
    const weeksToAdult = Math.max(adultWeek - ageWeeks, 0)

    this.predictedWeightTarget.textContent = `${predictedWeight.toFixed(1)} lbs`
    this.predictedWeightKgTarget.textContent = `${predictedWeightKg.toFixed(1)} kg`
    this.growthPercentageTarget.textContent = `${(growthPct * 100).toFixed(1)}%`
    this.remainingGrowthTarget.textContent = `${remainingGrowthPct.toFixed(1)}%`
    this.weeksToAdultTarget.textContent = `${weeksToAdult} weeks`
    this.breedRangeTarget.textContent = `${range.min}-${range.max} lbs`
  }

  interpolate(curve, ageWeeks) {
    const weeks = Object.keys(curve).map(Number).sort((a, b) => a - b)
    if (ageWeeks <= weeks[0]) return curve[weeks[0]]
    if (ageWeeks >= weeks[weeks.length - 1]) return curve[weeks[weeks.length - 1]]

    let lower = weeks[0], upper = weeks[weeks.length - 1]
    for (const w of weeks) {
      if (w <= ageWeeks) lower = w
      if (w > ageWeeks) { upper = w; break }
    }

    const ratio = (ageWeeks - lower) / (upper - lower)
    return curve[lower] + (curve[upper] - curve[lower]) * ratio
  }

  clearResults() {
    this.predictedWeightTarget.textContent = "\u2014"
    this.predictedWeightKgTarget.textContent = "\u2014"
    this.growthPercentageTarget.textContent = "\u2014"
    this.remainingGrowthTarget.textContent = "\u2014"
    this.weeksToAdultTarget.textContent = "\u2014"
    this.breedRangeTarget.textContent = "\u2014"
  }

  copy() {
    const text = [
      `Predicted Adult Weight: ${this.predictedWeightTarget.textContent} (${this.predictedWeightKgTarget.textContent})`,
      `Current Growth: ${this.growthPercentageTarget.textContent}`,
      `Remaining Growth: ${this.remainingGrowthTarget.textContent}`,
      `Weeks to Adult: ${this.weeksToAdultTarget.textContent}`,
      `Breed Range: ${this.breedRangeTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
