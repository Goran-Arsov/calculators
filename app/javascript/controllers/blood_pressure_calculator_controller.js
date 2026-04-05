import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["systolic", "diastolic",
                     "category", "riskLevel", "pulsePressure", "map", "recommendation"]

  calculate() {
    const systolic = parseInt(this.systolicTarget.value) || 0
    const diastolic = parseInt(this.diastolicTarget.value) || 0

    if (systolic <= 0 || diastolic <= 0 || systolic <= diastolic) {
      this.clearResults()
      return
    }

    let category, risk, recommendation
    if (systolic >= 180 || diastolic >= 120) {
      category = "Hypertensive Crisis"
      risk = "Critical"
      recommendation = "This reading indicates a hypertensive crisis. If you have symptoms such as chest pain, shortness of breath, or vision changes, call emergency services immediately."
    } else if (systolic >= 140 || diastolic >= 90) {
      category = "High Blood Pressure Stage 2"
      risk = "High"
      recommendation = "You may have Stage 2 hypertension. See your healthcare provider promptly. A combination of lifestyle changes and medication is typically recommended."
    } else if (systolic >= 130 || diastolic >= 80) {
      category = "High Blood Pressure Stage 1"
      risk = "Moderate"
      recommendation = "You may have Stage 1 hypertension. Consult your healthcare provider about lifestyle modifications and whether medication is needed."
    } else if (systolic >= 120 && diastolic < 80) {
      category = "Elevated"
      risk = "Moderate"
      recommendation = "Your blood pressure is slightly above normal. Lifestyle changes such as reducing sodium, increasing exercise, and managing stress can help."
    } else if (systolic < 90 || diastolic < 60) {
      category = "Hypotension"
      risk = "Low"
      recommendation = "Your blood pressure is lower than normal. If you experience dizziness or fainting, consult your doctor."
    } else {
      category = "Normal"
      risk = "Low"
      recommendation = "Your blood pressure is within the healthy range. Continue maintaining a healthy lifestyle."
    }

    const pulsePressure = systolic - diastolic
    const map = diastolic + (pulsePressure / 3)

    this.categoryTarget.textContent = category
    this.riskLevelTarget.textContent = risk
    this.pulsePressureTarget.textContent = `${pulsePressure} mmHg`
    this.mapTarget.textContent = `${map.toFixed(1)} mmHg`
    this.recommendationTarget.textContent = recommendation

    // Color coding
    const colorMap = {
      "Hypotension": "text-blue-600 dark:text-blue-400",
      "Normal": "text-green-600 dark:text-green-400",
      "Elevated": "text-yellow-600 dark:text-yellow-400",
      "High Blood Pressure Stage 1": "text-orange-600 dark:text-orange-400",
      "High Blood Pressure Stage 2": "text-red-600 dark:text-red-400",
      "Hypertensive Crisis": "text-red-700 dark:text-red-300"
    }
    this.categoryTarget.className = `text-xl font-bold ${colorMap[category] || "text-gray-600"}`
  }

  clearResults() {
    this.categoryTarget.textContent = "—"
    this.categoryTarget.className = "text-xl font-bold text-gray-400"
    this.riskLevelTarget.textContent = "—"
    this.pulsePressureTarget.textContent = "—"
    this.mapTarget.textContent = "—"
    this.recommendationTarget.textContent = "Enter your blood pressure reading to see your results."
  }

  copy() {
    const text = [
      `Blood Pressure: ${this.systolicTarget.value}/${this.diastolicTarget.value} mmHg`,
      `Category: ${this.categoryTarget.textContent}`,
      `Risk Level: ${this.riskLevelTarget.textContent}`,
      `Pulse Pressure: ${this.pulsePressureTarget.textContent}`,
      `Mean Arterial Pressure: ${this.mapTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
