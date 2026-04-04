import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "grade1", "grade2", "grade3", "grade4", "grade5", "grade6",
    "credits1", "credits2", "credits3", "credits4", "credits5", "credits6",
    "resultGpa", "resultTotalCredits", "resultQualityPoints"
  ]

  static gradePoints = {
    "A": 4.0, "A-": 3.7,
    "B+": 3.3, "B": 3.0, "B-": 2.7,
    "C+": 2.3, "C": 2.0, "C-": 1.7,
    "D+": 1.3, "D": 1.0,
    "F": 0.0
  }

  calculate() {
    let totalCredits = 0
    let totalQualityPoints = 0

    for (let i = 1; i <= 6; i++) {
      const grade = this[`grade${i}Target`].value
      const credits = parseFloat(this[`credits${i}Target`].value) || 0

      if (grade && credits > 0) {
        const points = this.constructor.gradePoints[grade]
        if (points !== undefined) {
          totalQualityPoints += points * credits
          totalCredits += credits
        }
      }
    }

    const gpa = totalCredits > 0 ? totalQualityPoints / totalCredits : 0

    this.resultGpaTarget.textContent = this.fmt(gpa)
    this.resultTotalCreditsTarget.textContent = this.fmt(totalCredits)
    this.resultQualityPointsTarget.textContent = this.fmt(totalQualityPoints)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
