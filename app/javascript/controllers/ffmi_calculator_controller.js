import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["weightKg", "heightCm", "bodyFatPercent",
                     "leanMassKg", "fatMassKg", "ffmi", "adjustedFfmi", "category"]

  connect() {
    prefillFromUrl(this, { weight_kg: "weightKg", height_cm: "heightCm", body_fat_percent: "bodyFatPercent" })
    this.calculate()
  }

  calculate() {
    const weightKg = parseFloat(this.weightKgTarget.value) || 0
    const heightCm = parseFloat(this.heightCmTarget.value) || 0
    const bodyFatPercent = parseFloat(this.bodyFatPercentTarget.value) || 0

    if (weightKg <= 0 || heightCm <= 0 || bodyFatPercent < 0 || bodyFatPercent > 70) {
      this.clearResults()
      return
    }

    const heightM = heightCm / 100.0
    const leanMassKg = weightKg * (1 - bodyFatPercent / 100.0)
    const fatMassKg = weightKg - leanMassKg
    const ffmi = leanMassKg / (heightM * heightM)
    const adjustedFfmi = ffmi + 6.1 * (1.8 - heightM)

    let category
    if (adjustedFfmi < 18) category = "Below Average"
    else if (adjustedFfmi < 20) category = "Average"
    else if (adjustedFfmi < 22) category = "Above Average"
    else if (adjustedFfmi < 25) category = "Excellent"
    else category = "Superior / Elite"

    this.leanMassKgTarget.textContent = leanMassKg.toFixed(2)
    this.fatMassKgTarget.textContent = fatMassKg.toFixed(2)
    this.ffmiTarget.textContent = ffmi.toFixed(2)
    this.adjustedFfmiTarget.textContent = adjustedFfmi.toFixed(2)
    this.categoryTarget.textContent = category
  }

  clearResults() {
    this.leanMassKgTarget.textContent = "—"
    this.fatMassKgTarget.textContent = "—"
    this.ffmiTarget.textContent = "—"
    this.adjustedFfmiTarget.textContent = "—"
    this.categoryTarget.textContent = "—"
  }

  copy() {
    const text = `FFMI: ${this.ffmiTarget.textContent}\nAdjusted FFMI: ${this.adjustedFfmiTarget.textContent}\nCategory: ${this.categoryTarget.textContent}\nLean Mass: ${this.leanMassKgTarget.textContent} kg\nFat Mass: ${this.fatMassKgTarget.textContent} kg`
    navigator.clipboard.writeText(text)
  }
}
