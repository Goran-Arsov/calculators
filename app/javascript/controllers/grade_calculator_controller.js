import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "score1", "score2", "score3", "score4", "score5", "score6",
    "weight1", "weight2", "weight3", "weight4", "weight5", "weight6",
    "resultAverage", "resultLetter", "resultTotalWeight"
  ]

  static letterGrades = [
    { min: 97, letter: "A+" },
    { min: 93, letter: "A" },
    { min: 90, letter: "A-" },
    { min: 87, letter: "B+" },
    { min: 83, letter: "B" },
    { min: 80, letter: "B-" },
    { min: 77, letter: "C+" },
    { min: 73, letter: "C" },
    { min: 70, letter: "C-" },
    { min: 67, letter: "D+" },
    { min: 63, letter: "D" },
    { min: 60, letter: "D-" },
    { min: 0,  letter: "F" }
  ]

  calculate() {
    let weightedSum = 0
    let totalWeight = 0

    for (let i = 1; i <= 6; i++) {
      const score = parseFloat(this[`score${i}Target`].value) || 0
      const weight = parseFloat(this[`weight${i}Target`].value) || 0

      if (weight > 0) {
        weightedSum += score * weight
        totalWeight += weight
      }
    }

    const average = totalWeight > 0 ? weightedSum / totalWeight : 0
    const letter = this.getLetterGrade(average)

    this.resultAverageTarget.textContent = average.toFixed(2) + "%"
    this.resultLetterTarget.textContent = letter
    this.resultTotalWeightTarget.textContent = totalWeight.toFixed(1) + "%"
  }

  getLetterGrade(avg) {
    for (const g of this.constructor.letterGrades) {
      if (avg >= g.min) return g.letter
    }
    return "F"
  }

  copy() {
    const avg = this.resultAverageTarget.textContent
    const letter = this.resultLetterTarget.textContent
    const totalWeight = this.resultTotalWeightTarget.textContent
    const text = `Weighted Average: ${avg}\nLetter Grade: ${letter}\nTotal Weight: ${totalWeight}`
    navigator.clipboard.writeText(text)
  }
}
