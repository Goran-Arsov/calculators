import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "watts1", "hours1", "qty1",
    "watts2", "hours2", "qty2",
    "watts3", "hours3", "qty3",
    "watts4", "hours4", "qty4",
    "watts5", "hours5", "qty5",
    "watts6", "hours6", "qty6",
    "rate",
    "resultDailyKwh", "resultMonthlyKwh", "resultMonthlyCost",
    "resultYearlyKwh", "resultYearlyCost"
  ]

  calculate() {
    const rate = parseFloat(this.rateTarget.value) || 0
    let totalDailyKwh = 0

    for (let i = 1; i <= 6; i++) {
      const watts = parseFloat(this[`watts${i}Target`].value) || 0
      const hours = parseFloat(this[`hours${i}Target`].value) || 0
      const qty = parseInt(this[`qty${i}Target`].value) || 1

      if (watts > 0 && hours > 0) {
        totalDailyKwh += (watts * hours * qty) / 1000
      }
    }

    const monthlyKwh = totalDailyKwh * 30
    const monthlyCost = monthlyKwh * rate
    const yearlyKwh = totalDailyKwh * 365
    const yearlyCost = yearlyKwh * rate

    this.resultDailyKwhTarget.textContent = totalDailyKwh.toFixed(2) + " kWh"
    this.resultMonthlyKwhTarget.textContent = monthlyKwh.toFixed(1) + " kWh"
    this.resultMonthlyCostTarget.textContent = "$" + monthlyCost.toFixed(2)
    this.resultYearlyKwhTarget.textContent = yearlyKwh.toFixed(1) + " kWh"
    this.resultYearlyCostTarget.textContent = "$" + yearlyCost.toFixed(2)
  }

  copy() {
    const daily = this.resultDailyKwhTarget.textContent
    const mKwh = this.resultMonthlyKwhTarget.textContent
    const mCost = this.resultMonthlyCostTarget.textContent
    const yKwh = this.resultYearlyKwhTarget.textContent
    const yCost = this.resultYearlyCostTarget.textContent
    const text = `Daily: ${daily}\nMonthly: ${mKwh} (${mCost})\nYearly: ${yKwh} (${yCost})`
    navigator.clipboard.writeText(text)
  }
}
