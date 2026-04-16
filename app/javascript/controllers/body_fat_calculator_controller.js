import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["sex", "waist", "neck", "height", "hip", "unitSystem",
                     "hipField", "bodyFat", "category",
                     "waistLabel", "neckLabel", "heightLabel", "hipLabel"]
  static values = {
    waistMetric: { type: String, default: "Waist (cm)" },
    waistImperial: { type: String, default: "Waist (inches)" },
    neckMetric: { type: String, default: "Neck (cm)" },
    neckImperial: { type: String, default: "Neck (inches)" },
    heightMetric: { type: String, default: "Height (cm)" },
    heightImperial: { type: String, default: "Height (inches)" },
    hipMetric: { type: String, default: "Hip (cm)" },
    hipImperial: { type: String, default: "Hip (inches)" },
    categoryEssential: { type: String, default: "Essential fat" },
    categoryAthletes: { type: String, default: "Athletes" },
    categoryFitness: { type: String, default: "Fitness" },
    categoryAverage: { type: String, default: "Average" },
    categoryObese: { type: String, default: "Obese" }
  }

  connect() {
    prefillFromUrl(this, { waist: "waist", neck: "neck", height: "height", hip: "hip", sex: "sex", unit: "unitSystem" })
    this.updateFields()
  }

  updateFields() {
    const sex = this.sexTarget.value
    this.hipFieldTarget.classList.toggle("hidden", sex === "male")
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const unit = this.unitSystemTarget.value
    this.waistLabelTarget.textContent = unit === "imperial" ? this.waistImperialValue : this.waistMetricValue
    this.neckLabelTarget.textContent = unit === "imperial" ? this.neckImperialValue : this.neckMetricValue
    this.heightLabelTarget.textContent = unit === "imperial" ? this.heightImperialValue : this.heightMetricValue
    this.hipLabelTarget.textContent = unit === "imperial" ? this.hipImperialValue : this.hipMetricValue
    this.calculate()
  }

  calculate() {
    const sex = this.sexTarget.value
    const unit = this.unitSystemTarget.value
    let waist = parseFloat(this.waistTarget.value) || 0
    let neck = parseFloat(this.neckTarget.value) || 0
    let height = parseFloat(this.heightTarget.value) || 0
    let hip = parseFloat(this.hipTarget.value) || 0

    if (waist <= 0 || neck <= 0 || height <= 0 || waist <= neck) {
      this.clearResults()
      return
    }

    if (sex === "female" && hip <= 0) {
      this.clearResults()
      return
    }

    // Convert to cm if imperial
    if (unit === "imperial") {
      waist *= 2.54; neck *= 2.54; height *= 2.54; hip *= 2.54
    }

    let bodyFat
    if (sex === "male") {
      bodyFat = 495 / (1.0324 - 0.19077 * Math.log10(waist - neck) + 0.15456 * Math.log10(height)) - 450
    } else {
      bodyFat = 495 / (1.29579 - 0.35004 * Math.log10(waist + hip - neck) + 0.22100 * Math.log10(height)) - 450
    }

    let category
    if (sex === "male") {
      if (bodyFat < 6) category = this.categoryEssentialValue
      else if (bodyFat < 14) category = this.categoryAthletesValue
      else if (bodyFat < 18) category = this.categoryFitnessValue
      else if (bodyFat < 25) category = this.categoryAverageValue
      else category = this.categoryObeseValue
    } else {
      if (bodyFat < 14) category = this.categoryEssentialValue
      else if (bodyFat < 21) category = this.categoryAthletesValue
      else if (bodyFat < 25) category = this.categoryFitnessValue
      else if (bodyFat < 32) category = this.categoryAverageValue
      else category = this.categoryObeseValue
    }

    this.bodyFatTarget.textContent = bodyFat.toFixed(1) + "%"
    this.categoryTarget.textContent = category
  }

  clearResults() {
    this.bodyFatTarget.textContent = "0%"
    this.categoryTarget.textContent = "—"
  }

  copy() {
    const text = `Body Fat: ${this.bodyFatTarget.textContent}\nCategory: ${this.categoryTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
