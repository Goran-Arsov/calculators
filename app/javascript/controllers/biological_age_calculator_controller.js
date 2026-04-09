import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["age", "exercise", "sleep", "diet", "stress", "smoker", "bmi",
                     "biologicalAge", "ageDifference", "exerciseAdj", "sleepAdj",
                     "dietAdj", "stressAdj", "smokingAdj", "bmiAdj", "recommendations"]

  connect() {
    prefillFromUrl(this, {
      age: "age", exercise: "exercise", sleep: "sleep",
      diet: "diet", stress: "stress", smoker: "smoker", bmi: "bmi"
    })
    this.calculate()
  }

  calculate() {
    const age = parseInt(this.ageTarget.value) || 0
    const exercise = parseFloat(this.exerciseTarget.value) || 0
    const sleep = parseFloat(this.sleepTarget.value) || 0
    const diet = parseInt(this.dietTarget.value) || 0
    const stress = parseInt(this.stressTarget.value) || 0
    const isSmoker = this.smokerTarget.value === "yes"
    const bmi = parseFloat(this.bmiTarget.value) || 0

    if (age <= 0 || bmi <= 0) {
      this.clearResults()
      return
    }

    // Exercise adjustment
    let exerciseAdj
    if (exercise > 5) exerciseAdj = -3
    else if (exercise >= 3) exerciseAdj = -2
    else if (exercise >= 1) exerciseAdj = -1
    else exerciseAdj = 1

    // Sleep adjustment
    let sleepAdj
    if (sleep >= 7 && sleep <= 9) sleepAdj = -1
    else if (sleep >= 6 && sleep < 7) sleepAdj = 0
    else sleepAdj = 2

    // Diet adjustment
    let dietAdj
    if (diet === 5) dietAdj = -3
    else if (diet === 4) dietAdj = -1
    else if (diet === 3) dietAdj = 0
    else if (diet === 2) dietAdj = 1
    else dietAdj = 3

    // Stress adjustment
    let stressAdj
    if (stress === 1) stressAdj = -2
    else if (stress === 2) stressAdj = -1
    else if (stress === 3) stressAdj = 0
    else if (stress === 4) stressAdj = 2
    else stressAdj = 4

    // Smoking adjustment
    const smokingAdj = isSmoker ? 5 : 0

    // BMI adjustment
    let bmiAdj
    if (bmi >= 18.5 && bmi < 25) bmiAdj = -1
    else if (bmi >= 25 && bmi < 30) bmiAdj = 1
    else if (bmi >= 30) bmiAdj = 3
    else bmiAdj = 1

    const totalAdj = exerciseAdj + sleepAdj + dietAdj + stressAdj + smokingAdj + bmiAdj
    const biologicalAge = age + totalAdj

    this.biologicalAgeTarget.textContent = biologicalAge
    this.ageDifferenceTarget.textContent = (totalAdj >= 0 ? "+" : "") + totalAdj + " years"

    this.exerciseAdjTarget.textContent = this.formatAdj(exerciseAdj)
    this.sleepAdjTarget.textContent = this.formatAdj(sleepAdj)
    this.dietAdjTarget.textContent = this.formatAdj(dietAdj)
    this.stressAdjTarget.textContent = this.formatAdj(stressAdj)
    this.smokingAdjTarget.textContent = this.formatAdj(smokingAdj)
    this.bmiAdjTarget.textContent = this.formatAdj(bmiAdj)

    // Generate recommendations
    const recs = []
    if (smokingAdj > 0) recs.push("Quitting smoking could reduce your biological age by up to 5 years.")
    if (stressAdj > 0) recs.push("Reducing stress through meditation, exercise, or therapy could lower your biological age.")
    if (exerciseAdj >= 0) recs.push("Increasing physical activity to at least 3-5 hours per week can significantly improve your biological age.")
    if (dietAdj > 0) recs.push("Improving your diet quality with more whole foods, fruits, and vegetables can reduce biological aging.")
    if (sleepAdj > 0) recs.push("Aim for 7-9 hours of quality sleep per night to support cellular repair and longevity.")
    if (bmiAdj > 0) recs.push("Working toward a BMI in the 18.5-24.9 range can improve your overall health markers.")

    const topRecs = recs.slice(0, 3)
    if (topRecs.length > 0) {
      this.recommendationsTarget.innerHTML = topRecs.map(r => `<li class="text-sm text-gray-600 dark:text-gray-400">${r}</li>`).join("")
    } else {
      this.recommendationsTarget.innerHTML = '<li class="text-sm text-green-600 dark:text-green-400">Great job! Your lifestyle factors are all contributing positively to your biological age.</li>'
    }
  }

  formatAdj(value) {
    return (value >= 0 ? "+" : "") + value + " yrs"
  }

  clearResults() {
    this.biologicalAgeTarget.textContent = "—"
    this.ageDifferenceTarget.textContent = "—"
    this.exerciseAdjTarget.textContent = "—"
    this.sleepAdjTarget.textContent = "—"
    this.dietAdjTarget.textContent = "—"
    this.stressAdjTarget.textContent = "—"
    this.smokingAdjTarget.textContent = "—"
    this.bmiAdjTarget.textContent = "—"
    this.recommendationsTarget.innerHTML = ""
  }

  copy() {
    const text = [
      `Biological Age: ${this.biologicalAgeTarget.textContent}`,
      `Age Difference: ${this.ageDifferenceTarget.textContent}`,
      `Exercise: ${this.exerciseAdjTarget.textContent}`,
      `Sleep: ${this.sleepAdjTarget.textContent}`,
      `Diet: ${this.dietAdjTarget.textContent}`,
      `Stress: ${this.stressAdjTarget.textContent}`,
      `Smoking: ${this.smokingAdjTarget.textContent}`,
      `BMI: ${this.bmiAdjTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
