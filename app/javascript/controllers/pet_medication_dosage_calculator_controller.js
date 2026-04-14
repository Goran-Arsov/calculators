import { Controller } from "@hotwired/stimulus"
import { LB_TO_KG } from "utils/units"

export default class extends Controller {
  static targets = ["petType", "weight", "medication",
                     "medicationName", "minDose", "maxDose", "frequency", "doseRange",
                     "unitSystem", "weightLabel"]

  static medications = {
    benadryl: {
      name: "Benadryl (Diphenhydramine)",
      dog: { min: 2.0, max: 4.0, freq: "Every 8-12 hours" },
      cat: { min: 1.0, max: 2.0, freq: "Every 8-12 hours" }
    },
    pepcid: {
      name: "Pepcid (Famotidine)",
      dog: { min: 0.5, max: 1.0, freq: "Every 12-24 hours" },
      cat: { min: 0.5, max: 1.0, freq: "Every 12-24 hours" }
    },
    bayer_aspirin: {
      name: "Aspirin (Buffered)",
      dog: { min: 10.0, max: 20.0, freq: "Every 12 hours" },
      cat: { min: 6.0, max: 10.0, freq: "Every 48-72 hours" }
    },
    glucosamine: {
      name: "Glucosamine",
      dog: { min: 20.0, max: 25.0, freq: "Once daily" },
      cat: { min: 10.0, max: 15.0, freq: "Once daily" }
    },
    fish_oil: {
      name: "Fish Oil (EPA + DHA)",
      dog: { min: 50.0, max: 75.0, freq: "Once daily" },
      cat: { min: 30.0, max: 50.0, freq: "Once daily" }
    },
    melatonin: {
      name: "Melatonin",
      dog: { min: 0.05, max: 0.1, freq: "Every 8-12 hours" },
      cat: { min: 0.05, max: 0.1, freq: "Every 8-12 hours" }
    },
    probiotics: {
      name: "Probiotics",
      dog: { min: 1.0, max: 5.0, freq: "Once daily" },
      cat: { min: 1.0, max: 3.0, freq: "Once daily" }
    }
  }

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const n = parseFloat(this.weightTarget.value)
    if (Number.isFinite(n)) {
      this.weightTarget.value = (toMetric ? n * LB_TO_KG : n / LB_TO_KG).toFixed(2)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.weightLabelTarget.textContent = metric ? "Pet's Weight (kg)" : "Pet's Weight (lbs)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const petType = this.petTypeTarget.value
    const weightInput = parseFloat(this.weightTarget.value) || 0
    const medication = this.medicationTarget.value

    if (weightInput <= 0 || !medication) {
      this.clearResults()
      return
    }

    const med = this.constructor.medications[medication]
    if (!med) {
      this.clearResults()
      return
    }

    const dosageInfo = med[petType]
    if (!dosageInfo) {
      this.clearResults()
      return
    }

    const weightKg = metric ? weightInput : weightInput * LB_TO_KG
    const minDose = weightKg * dosageInfo.min
    const maxDose = weightKg * dosageInfo.max

    this.medicationNameTarget.textContent = med.name
    this.minDoseTarget.textContent = `${minDose.toFixed(1)} mg`
    this.maxDoseTarget.textContent = `${maxDose.toFixed(1)} mg`
    this.frequencyTarget.textContent = dosageInfo.freq
    this.doseRangeTarget.textContent = `${dosageInfo.min}-${dosageInfo.max} mg/kg`
  }

  clearResults() {
    this.medicationNameTarget.textContent = "\u2014"
    this.minDoseTarget.textContent = "\u2014"
    this.maxDoseTarget.textContent = "\u2014"
    this.frequencyTarget.textContent = "\u2014"
    this.doseRangeTarget.textContent = "\u2014"
  }

  copy() {
    const text = [
      `Medication: ${this.medicationNameTarget.textContent}`,
      `Dose Range: ${this.doseRangeTarget.textContent}`,
      `Min Dose: ${this.minDoseTarget.textContent}`,
      `Max Dose: ${this.maxDoseTarget.textContent}`,
      `Frequency: ${this.frequencyTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
