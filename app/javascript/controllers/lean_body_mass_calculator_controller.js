import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "bodyFatPct", "gender", "height", "unitSystem",
                     "leanMass", "fatMass", "bodyFatResult", "leanPct",
                     "boer", "james", "hume", "method",
                     "weightLabel", "heightLabel", "formulaFields"]

  connect() {
    this.updateLabels()
    this.updateMethod()
  }

  updateLabels() {
    const unit = this.unitSystemTarget.value
    this.weightLabelTarget.textContent = unit === "imperial" ? "Weight (lbs)" : "Weight (kg)"
    if (this.hasHeightLabelTarget) {
      this.heightLabelTarget.textContent = unit === "imperial" ? "Height (inches)" : "Height (cm)"
    }
    this.calculate()
  }

  updateMethod() {
    const method = this.methodTarget.value
    if (method === "body_fat") {
      this.bodyFatPctTarget.closest(".field-group").classList.remove("hidden")
      this.formulaFieldsTarget.classList.add("hidden")
    } else {
      this.bodyFatPctTarget.closest(".field-group").classList.add("hidden")
      this.formulaFieldsTarget.classList.remove("hidden")
    }
    this.calculate()
  }

  calculate() {
    const weight = parseFloat(this.weightTarget.value) || 0
    const unit = this.unitSystemTarget.value
    const method = this.methodTarget.value

    if (weight <= 0) {
      this.clearResults()
      return
    }

    if (method === "body_fat") {
      this.calculateFromBodyFat(weight, unit)
    } else {
      this.calculateFromFormula(weight, unit)
    }
  }

  calculateFromBodyFat(weight, unit) {
    const bfPct = parseFloat(this.bodyFatPctTarget.value) || 0
    if (bfPct <= 0 || bfPct > 70) {
      this.clearResults()
      return
    }

    const fatMass = weight * bfPct / 100
    const leanMass = weight - fatMass
    const leanPct = 100 - bfPct
    const unitLabel = unit === "imperial" ? "lbs" : "kg"

    this.leanMassTarget.textContent = `${leanMass.toFixed(1)} ${unitLabel}`
    this.fatMassTarget.textContent = `${fatMass.toFixed(1)} ${unitLabel}`
    this.bodyFatResultTarget.textContent = `${bfPct.toFixed(1)}%`
    this.leanPctTarget.textContent = `${leanPct.toFixed(1)}%`

    // Hide formula comparison for body fat method
    if (this.hasBoerTarget) this.boerTarget.closest(".formula-row").classList.add("hidden")
    if (this.hasJamesTarget) this.jamesTarget.closest(".formula-row").classList.add("hidden")
    if (this.hasHumeTarget) this.humeTarget.closest(".formula-row").classList.add("hidden")
  }

  calculateFromFormula(weight, unit) {
    const gender = this.genderTarget.value
    const height = parseFloat(this.heightTarget.value) || 0

    if (height <= 0) {
      this.clearResults()
      return
    }

    const weightKg = unit === "imperial" ? weight * 0.453592 : weight
    const heightCm = unit === "imperial" ? height * 2.54 : height

    let boer, james, hume
    if (gender === "male") {
      boer = 0.407 * weightKg + 0.267 * heightCm - 19.2
      james = 1.1 * weightKg - 128.0 * Math.pow(weightKg / heightCm, 2)
      hume = 0.32810 * weightKg + 0.33929 * heightCm - 29.5336
    } else {
      boer = 0.252 * weightKg + 0.473 * heightCm - 48.3
      james = 1.07 * weightKg - 148.0 * Math.pow(weightKg / heightCm, 2)
      hume = 0.29569 * weightKg + 0.41813 * heightCm - 43.2933
    }

    const leanMassKg = boer
    const fatMassKg = weightKg - leanMassKg
    const bfPct = (fatMassKg / weightKg) * 100

    const displayFactor = unit === "imperial" ? 2.20462 : 1
    const unitLabel = unit === "imperial" ? "lbs" : "kg"

    this.leanMassTarget.textContent = `${(leanMassKg * displayFactor).toFixed(1)} ${unitLabel}`
    this.fatMassTarget.textContent = `${(fatMassKg * displayFactor).toFixed(1)} ${unitLabel}`
    this.bodyFatResultTarget.textContent = `${bfPct.toFixed(1)}%`
    this.leanPctTarget.textContent = `${(100 - bfPct).toFixed(1)}%`

    // Show formula comparison
    if (this.hasBoerTarget) {
      this.boerTarget.closest(".formula-row").classList.remove("hidden")
      this.boerTarget.textContent = `${(boer * displayFactor).toFixed(1)} ${unitLabel}`
    }
    if (this.hasJamesTarget) {
      this.jamesTarget.closest(".formula-row").classList.remove("hidden")
      this.jamesTarget.textContent = `${(james * displayFactor).toFixed(1)} ${unitLabel}`
    }
    if (this.hasHumeTarget) {
      this.humeTarget.closest(".formula-row").classList.remove("hidden")
      this.humeTarget.textContent = `${(hume * displayFactor).toFixed(1)} ${unitLabel}`
    }
  }

  clearResults() {
    this.leanMassTarget.textContent = "—"
    this.fatMassTarget.textContent = "—"
    this.bodyFatResultTarget.textContent = "—"
    this.leanPctTarget.textContent = "—"
    if (this.hasBoerTarget) this.boerTarget.textContent = "—"
    if (this.hasJamesTarget) this.jamesTarget.textContent = "—"
    if (this.hasHumeTarget) this.humeTarget.textContent = "—"
  }

  copy() {
    const text = [
      `Lean Body Mass: ${this.leanMassTarget.textContent}`,
      `Fat Mass: ${this.fatMassTarget.textContent}`,
      `Body Fat: ${this.bodyFatResultTarget.textContent}`,
      `Lean Percentage: ${this.leanPctTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
