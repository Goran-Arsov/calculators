import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "currentGrade", "finalWeight", "desiredGrade",
    "resultRequiredGrade", "resultAchievable", "resultLetterNeeded", "resultCurrentLetter"
  ]

  connect() {
    prefillFromUrl(this, {
      current_grade: "currentGrade",
      final_weight: "finalWeight",
      desired_grade: "desiredGrade"
    })
    this.calculate()
  }

  calculate() {
    const current = parseFloat(this.currentGradeTarget.value) || 0
    const weight = parseFloat(this.finalWeightTarget.value) || 0
    const desired = parseFloat(this.desiredGradeTarget.value) || 0

    if (weight <= 0 || weight > 100) {
      this.resultRequiredGradeTarget.textContent = "—"
      this.resultAchievableTarget.textContent = "—"
      this.resultLetterNeededTarget.textContent = "—"
      this.resultCurrentLetterTarget.textContent = "—"
      return
    }

    const weightFraction = weight / 100
    const required = (desired - current * (1 - weightFraction)) / weightFraction
    const achievable = required <= 100 && required >= 0

    this.resultRequiredGradeTarget.textContent = required.toFixed(2) + "%"
    this.resultAchievableTarget.textContent = achievable ? "Yes" : "No"
    this.resultAchievableTarget.className = this.resultAchievableTarget.className.replace(/text-\w+-\d+/g, "")
    this.resultAchievableTarget.classList.add(achievable ? "text-green-600" : "text-red-600")
    this.resultLetterNeededTarget.textContent = this.letterGrade(required)
    this.resultCurrentLetterTarget.textContent = this.letterGrade(current)
  }

  letterGrade(score) {
    if (score >= 90) return "A"
    if (score >= 80) return "B"
    if (score >= 70) return "C"
    if (score >= 60) return "D"
    return "F"
  }

  copy() {
    const required = this.resultRequiredGradeTarget.textContent
    const achievable = this.resultAchievableTarget.textContent
    const letterNeeded = this.resultLetterNeededTarget.textContent
    const currentLetter = this.resultCurrentLetterTarget.textContent
    const text = `Required Final Grade: ${required}\nAchievable: ${achievable}\nLetter Grade Needed: ${letterNeeded}\nCurrent Letter Grade: ${currentLetter}`
    navigator.clipboard.writeText(text)
  }
}
