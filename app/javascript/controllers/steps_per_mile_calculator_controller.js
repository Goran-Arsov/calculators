import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalSteps", "distance", "unit",
    "stepsPerMile", "stepsPerKm", "estimatedCalories",
    "strideLengthFt", "strideLengthM"
  ]

  calculate() {
    const totalSteps = parseFloat(this.totalStepsTarget.value) || 0
    const distance = parseFloat(this.distanceTarget.value) || 0
    const unit = this.unitTarget.value

    if (totalSteps <= 0 || distance <= 0) {
      this.clearResults()
      return
    }

    const KM_PER_MILE = 1.60934
    const CALORIES_PER_STEP = 0.04

    const distMiles = unit === "km" ? distance / KM_PER_MILE : distance
    const distKm = unit === "km" ? distance : distance * KM_PER_MILE

    const stepsPerMile = totalSteps / distMiles
    const stepsPerKm = totalSteps / distKm
    const estimatedCalories = totalSteps * CALORIES_PER_STEP

    const strideFt = 5280 / stepsPerMile
    const strideM = strideFt * 0.3048

    this.stepsPerMileTarget.textContent = Math.round(stepsPerMile).toLocaleString("en-US")
    this.stepsPerKmTarget.textContent = Math.round(stepsPerKm).toLocaleString("en-US")
    this.estimatedCaloriesTarget.textContent = Math.round(estimatedCalories).toLocaleString("en-US") + " kcal"
    this.strideLengthFtTarget.textContent = strideFt.toFixed(2) + " ft"
    this.strideLengthMTarget.textContent = strideM.toFixed(2) + " m"
  }

  clearResults() {
    this.stepsPerMileTarget.textContent = "\u2014"
    this.stepsPerKmTarget.textContent = "\u2014"
    this.estimatedCaloriesTarget.textContent = "\u2014"
    this.strideLengthFtTarget.textContent = "\u2014"
    this.strideLengthMTarget.textContent = "\u2014"
  }

  copy() {
    const text = [
      `Steps per mile: ${this.stepsPerMileTarget.textContent}`,
      `Steps per km: ${this.stepsPerKmTarget.textContent}`,
      `Estimated calories: ${this.estimatedCaloriesTarget.textContent}`,
      `Stride length: ${this.strideLengthFtTarget.textContent} / ${this.strideLengthMTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
