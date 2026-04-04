import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "rent", "homePrice", "downPct", "interestRate", "years", "rentIncrease",
    "resultTotalRent", "resultTotalBuy", "resultSavings"
  ]

  calculate() {
    const monthlyRent = parseFloat(this.rentTarget.value) || 0
    const homePrice = parseFloat(this.homePriceTarget.value) || 0
    const downPct = parseFloat(this.downPctTarget.value) / 100 || 0
    const annualRate = parseFloat(this.interestRateTarget.value) / 100 || 0
    const years = parseInt(this.yearsTarget.value) || 0
    const rentIncrease = parseFloat(this.rentIncreaseTarget.value) / 100

    if (monthlyRent <= 0 || homePrice <= 0 || years <= 0) {
      this.resultTotalRentTarget.textContent = "—"
      this.resultTotalBuyTarget.textContent = "—"
      this.resultSavingsTarget.textContent = "—"
      return
    }

    // Total rent with annual increases
    let totalRent = 0
    let currentRent = monthlyRent
    for (let y = 0; y < years; y++) {
      totalRent += currentRent * 12
      currentRent *= (1 + (isNaN(rentIncrease) ? 0.03 : rentIncrease))
    }

    // Mortgage calculation
    const downPayment = homePrice * downPct
    const loanAmount = homePrice - downPayment
    const monthlyRate = annualRate / 12
    const numPayments = years * 12
    let totalMortgagePayments

    if (monthlyRate === 0) {
      totalMortgagePayments = loanAmount
    } else {
      const monthlyPayment = loanAmount * (monthlyRate * Math.pow(1 + monthlyRate, numPayments)) / (Math.pow(1 + monthlyRate, numPayments) - 1)
      totalMortgagePayments = monthlyPayment * numPayments
    }

    const totalBuy = totalMortgagePayments + downPayment
    const savings = totalRent - totalBuy

    this.resultTotalRentTarget.textContent = "$" + this.fmt(totalRent)
    this.resultTotalBuyTarget.textContent = "$" + this.fmt(totalBuy)
    this.resultSavingsTarget.textContent = (savings >= 0 ? "Buy saves $" : "Rent saves $") + this.fmt(Math.abs(savings))
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const result = card.querySelector("[data-result]")
    navigator.clipboard.writeText(`${card.dataset.card}: ${result.textContent}`)
  }
}
