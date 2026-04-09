import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["testType", "distanceMeters", "timeMinutes",
                     "age", "gender", "cooperFields", "mileFields",
                     "vo2Max", "fitnessLevel", "percentileEstimate"]

  connect() {
    prefillFromUrl(this, {
      test_type: "testType", distance_meters: "distanceMeters",
      time_minutes: "timeMinutes", age: "age", gender: "gender"
    })
    this.toggleFields()
  }

  toggleFields() {
    const testType = this.testTypeTarget.value
    if (testType === "cooper_12min") {
      this.cooperFieldsTarget.classList.remove("hidden")
      this.mileFieldsTarget.classList.add("hidden")
    } else {
      this.cooperFieldsTarget.classList.add("hidden")
      this.mileFieldsTarget.classList.remove("hidden")
    }
    this.calculate()
  }

  calculate() {
    const testType = this.testTypeTarget.value
    const age = parseInt(this.ageTarget.value) || 0
    const gender = this.genderTarget.value

    if (age < 13) {
      this.clearResults()
      return
    }

    let vo2Max
    if (testType === "cooper_12min") {
      const distance = parseFloat(this.distanceMetersTarget.value) || 0
      if (distance <= 0) { this.clearResults(); return }
      vo2Max = (distance - 504.9) / 44.73
    } else {
      const time = parseFloat(this.timeMinutesTarget.value) || 0
      if (time <= 0) { this.clearResults(); return }
      vo2Max = 483.0 / time + 3.5
    }

    const fitnessLevel = this.determineFitnessLevel(vo2Max, age, gender)
    const percentile = this.getPercentile(fitnessLevel)

    this.vo2MaxTarget.textContent = vo2Max.toFixed(1)
    this.fitnessLevelTarget.textContent = fitnessLevel.replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase())
    this.percentileEstimateTarget.textContent = `~${percentile}th`
  }

  determineFitnessLevel(vo2Max, age, gender) {
    const tables = {
      male: {
        "13-19": { poor: 35.0, below_average: 38.4, average: 45.2, above_average: 50.9, good: 55.9, excellent: 60.0 },
        "20-29": { poor: 33.0, below_average: 36.5, average: 42.4, above_average: 46.4, good: 52.4, excellent: 56.0 },
        "30-39": { poor: 31.5, below_average: 35.5, average: 40.9, above_average: 44.9, good: 49.4, excellent: 54.0 },
        "40-49": { poor: 30.2, below_average: 33.6, average: 38.9, above_average: 43.7, good: 48.0, excellent: 52.0 },
        "50-59": { poor: 26.1, below_average: 30.2, average: 35.7, above_average: 40.9, good: 45.3, excellent: 49.0 },
        "60+": { poor: 20.5, below_average: 26.1, average: 32.2, above_average: 36.4, good: 44.2, excellent: 48.0 }
      },
      female: {
        "13-19": { poor: 25.0, below_average: 31.0, average: 35.0, above_average: 38.9, good: 41.9, excellent: 45.0 },
        "20-29": { poor: 23.6, below_average: 28.9, average: 32.9, above_average: 36.9, good: 41.0, excellent: 44.0 },
        "30-39": { poor: 22.8, below_average: 27.0, average: 31.4, above_average: 35.6, good: 40.0, excellent: 43.0 },
        "40-49": { poor: 21.0, below_average: 24.5, average: 28.9, above_average: 32.8, good: 36.9, excellent: 41.0 },
        "50-59": { poor: 20.2, below_average: 22.8, average: 26.9, above_average: 31.4, good: 35.7, excellent: 38.0 },
        "60+": { poor: 17.5, below_average: 20.2, average: 24.4, above_average: 30.2, good: 31.4, excellent: 35.0 }
      }
    }

    const genderTable = tables[gender]
    if (!genderTable) return "average"

    let ageKey
    if (age <= 19) ageKey = "13-19"
    else if (age <= 29) ageKey = "20-29"
    else if (age <= 39) ageKey = "30-39"
    else if (age <= 49) ageKey = "40-49"
    else if (age <= 59) ageKey = "50-59"
    else ageKey = "60+"

    const thresholds = genderTable[ageKey]
    if (vo2Max < thresholds.poor) return "poor"
    if (vo2Max < thresholds.below_average) return "below_average"
    if (vo2Max < thresholds.average) return "average"
    if (vo2Max < thresholds.above_average) return "above_average"
    if (vo2Max < thresholds.good) return "good"
    if (vo2Max < thresholds.excellent) return "excellent"
    return "superior"
  }

  getPercentile(level) {
    const map = {
      poor: 10, below_average: 25, average: 50,
      above_average: 65, good: 75, excellent: 90, superior: 97
    }
    return map[level] || 50
  }

  clearResults() {
    this.vo2MaxTarget.textContent = "—"
    this.fitnessLevelTarget.textContent = "—"
    this.percentileEstimateTarget.textContent = "—"
  }

  copy() {
    const text = `VO2 Max: ${this.vo2MaxTarget.textContent} ml/kg/min\nFitness Level: ${this.fitnessLevelTarget.textContent}\nPercentile: ${this.percentileEstimateTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
