import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["weight", "height", "unitSystem", "bmi", "category", "healthyMin", "healthyMax",
                     "weightLabel", "heightLabel"]
  static values = {
    weightMetric: { type: String, default: "Weight (kg)" },
    weightImperial: { type: String, default: "Weight (lbs)" },
    heightMetric: { type: String, default: "Height (cm)" },
    heightImperial: { type: String, default: "Height (inches)" },
    categoryUnderweight: { type: String, default: "Underweight" },
    categoryNormal: { type: String, default: "Normal weight" },
    categoryOverweight: { type: String, default: "Overweight" },
    categoryObese: { type: String, default: "Obese" }
  }

  connect() {
    prefillFromUrl(this, { weight: "weight", height: "height", unit: "unitSystem" })
    this.updateLabels()
  }

  updateLabels() {
    const unit = this.unitSystemTarget.value
    this.weightLabelTarget.textContent = unit === "imperial" ? this.weightImperialValue : this.weightMetricValue
    this.heightLabelTarget.textContent = unit === "imperial" ? this.heightImperialValue : this.heightMetricValue
    this.calculate()
  }

  calculate() {
    const weight = parseFloat(this.weightTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const unit = this.unitSystemTarget.value

    if (weight <= 0 || height <= 0) {
      this.clearResults()
      return
    }

    let bmi
    if (unit === "imperial") {
      bmi = (weight / (height * height)) * 703
    } else {
      const heightM = height / 100
      bmi = weight / (heightM * heightM)
    }

    let category
    if (bmi < 18.5) category = this.categoryUnderweightValue
    else if (bmi < 25) category = this.categoryNormalValue
    else if (bmi < 30) category = this.categoryOverweightValue
    else category = this.categoryObeseValue

    let heightM = unit === "imperial" ? height * 0.0254 : height / 100
    let factor = unit === "imperial" ? 2.205 : 1
    const healthyMin = 18.5 * heightM * heightM * factor
    const healthyMax = 24.9 * heightM * heightM * factor

    this.bmiTarget.textContent = bmi.toFixed(1)
    this.categoryTarget.textContent = category
    this.healthyMinTarget.textContent = healthyMin.toFixed(1)
    this.healthyMaxTarget.textContent = healthyMax.toFixed(1)
  }

  clearResults() {
    this.bmiTarget.textContent = "0"
    this.categoryTarget.textContent = "—"
    this.healthyMinTarget.textContent = "0"
    this.healthyMaxTarget.textContent = "0"
  }

  copy() {
    const text = `BMI: ${this.bmiTarget.textContent}\nCategory: ${this.categoryTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
