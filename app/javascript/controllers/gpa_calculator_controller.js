import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "grade1", "grade2", "grade3", "grade4", "grade5", "grade6",
    "credits1", "credits2", "credits3", "credits4", "credits5", "credits6",
    "resultGpa", "resultTotalCredits", "resultQualityPoints"
  ]

  calculate() {
    let totalCredits = 0
    let totalQualityPoints = 0

    for (let i = 1; i <= 6; i++) {
      const gradeValue = this[`grade${i}Target`].value
      const credits = parseFloat(this[`credits${i}Target`].value) || 0

      if (gradeValue !== "" && credits > 0) {
        const points = parseFloat(gradeValue)
        if (!isNaN(points)) {
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

  copy() {
    const gpa = this.resultGpaTarget.textContent
    const totalCredits = this.resultTotalCreditsTarget.textContent
    const qualityPoints = this.resultQualityPointsTarget.textContent

    const text = `GPA: ${gpa}\nTotal Credits: ${totalCredits}\nQuality Points: ${qualityPoints}`

    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
