import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["weight", "height", "currentWeek",
                     "bmi", "bmiCategory", "totalGainMin", "totalGainMax",
                     "currentGainMin", "currentGainMax", "weeklyRate"]

  static iomGuidelines = {
    underweight:  { totalMin: 12.7, totalMax: 18.1, weeklyRate: 0.51 },
    normal:       { totalMin: 11.3, totalMax: 15.9, weeklyRate: 0.42 },
    overweight:   { totalMin: 6.8,  totalMax: 11.3, weeklyRate: 0.28 },
    obese:        { totalMin: 5.0,  totalMax: 9.1,  weeklyRate: 0.22 }
  }

  connect() {
    prefillFromUrl(this, { weight: "weight", height: "height", week: "currentWeek" })
    this.calculate()
  }

  calculate() {
    const weight = parseFloat(this.weightTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const week = parseInt(this.currentWeekTarget.value) || 0

    if (weight <= 0 || height <= 0 || week < 1 || week > 42) {
      this.clearResults()
      return
    }

    const heightM = height / 100
    const bmi = weight / (heightM * heightM)

    let category
    if (bmi < 18.5) category = "underweight"
    else if (bmi < 25) category = "normal"
    else if (bmi < 30) category = "overweight"
    else category = "obese"

    const categoryLabels = {
      underweight: "Underweight",
      normal: "Normal weight",
      overweight: "Overweight",
      obese: "Obese"
    }

    const guidelines = this.constructor.iomGuidelines[category]
    const weeklyRate = guidelines.weeklyRate

    let currentGainMin, currentGainMax
    if (week <= 13) {
      const fraction = week / 13
      currentGainMin = 0.5 * fraction
      currentGainMax = 2.0 * fraction
    } else {
      const weeksPast = week - 13
      const additional = weeklyRate * weeksPast
      currentGainMin = 0.5 + additional
      currentGainMax = 2.0 + additional
    }

    this.bmiTarget.textContent = bmi.toFixed(1)
    this.bmiCategoryTarget.textContent = categoryLabels[category]
    this.totalGainMinTarget.textContent = guidelines.totalMin.toFixed(1) + " kg"
    this.totalGainMaxTarget.textContent = guidelines.totalMax.toFixed(1) + " kg"
    this.currentGainMinTarget.textContent = currentGainMin.toFixed(1) + " kg"
    this.currentGainMaxTarget.textContent = currentGainMax.toFixed(1) + " kg"
    this.weeklyRateTarget.textContent = weeklyRate.toFixed(2) + " kg/week"
  }

  clearResults() {
    this.bmiTarget.textContent = "—"
    this.bmiCategoryTarget.textContent = "—"
    this.totalGainMinTarget.textContent = "—"
    this.totalGainMaxTarget.textContent = "—"
    this.currentGainMinTarget.textContent = "—"
    this.currentGainMaxTarget.textContent = "—"
    this.weeklyRateTarget.textContent = "—"
  }

  copy() {
    const text = [
      `Pre-pregnancy BMI: ${this.bmiTarget.textContent}`,
      `BMI Category: ${this.bmiCategoryTarget.textContent}`,
      `Recommended Total Gain: ${this.totalGainMinTarget.textContent} – ${this.totalGainMaxTarget.textContent}`,
      `Current Expected Gain: ${this.currentGainMinTarget.textContent} – ${this.currentGainMaxTarget.textContent}`,
      `Weekly Gain Rate: ${this.weeklyRateTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
