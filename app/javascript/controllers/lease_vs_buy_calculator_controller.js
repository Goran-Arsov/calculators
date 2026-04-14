import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "vehiclePrice", "downPaymentBuy", "loanRate", "loanTermMonths",
    "leaseMonthlyPayment", "leaseTermMonths", "leaseDownPayment", "estimatedResaleValue",
    "buyMonthlyPayment", "totalBuyCost", "totalBuyNet",
    "totalLeaseCost", "savingsAmount", "recommendation"
  ]

  connect() {
    prefillFromUrl(this, {
      vehicle_price: "vehiclePrice", down_payment: "downPaymentBuy", loan_rate: "loanRate",
      loan_term: "loanTermMonths", lease_payment: "leaseMonthlyPayment", lease_term: "leaseTermMonths",
      lease_down: "leaseDownPayment", resale: "estimatedResaleValue"
    })
    this.calculate()
  }

  calculate() {
    const vehiclePrice = parseFloat(this.vehiclePriceTarget.value) || 0
    const downPaymentBuy = parseFloat(this.downPaymentBuyTarget.value) || 0
    const loanRatePercent = parseFloat(this.loanRateTarget.value) || 0
    const loanTermMonths = parseInt(this.loanTermMonthsTarget.value) || 0
    const leaseMonthlyPayment = parseFloat(this.leaseMonthlyPaymentTarget.value) || 0
    const leaseTermMonths = parseInt(this.leaseTermMonthsTarget.value) || 0
    const leaseDownPayment = parseFloat(this.leaseDownPaymentTarget.value) || 0
    const estimatedResaleValue = parseFloat(this.estimatedResaleValueTarget.value) || 0

    if (vehiclePrice <= 0 || loanTermMonths <= 0 || leaseTermMonths <= 0) {
      this.clearResults()
      return
    }

    // Buy scenario
    const loanAmount = vehiclePrice - downPaymentBuy
    const monthlyRate = loanRatePercent / 100 / 12
    let buyMonthlyPayment

    if (monthlyRate === 0) {
      buyMonthlyPayment = loanAmount / loanTermMonths
    } else {
      buyMonthlyPayment = loanAmount * (monthlyRate * Math.pow(1 + monthlyRate, loanTermMonths)) /
                          (Math.pow(1 + monthlyRate, loanTermMonths) - 1)
    }

    const totalBuyCost = downPaymentBuy + (buyMonthlyPayment * loanTermMonths)
    const totalBuyNet = totalBuyCost - estimatedResaleValue

    // Lease scenario
    const totalLeaseCost = leaseDownPayment + (leaseMonthlyPayment * leaseTermMonths)

    // Compare
    const savingsAmount = Math.abs(totalLeaseCost - totalBuyNet)
    const rec = totalBuyNet <= totalLeaseCost ? "Buy" : "Lease"

    this.buyMonthlyPaymentTarget.textContent = formatCurrency(buyMonthlyPayment)
    this.totalBuyCostTarget.textContent = formatCurrency(totalBuyCost)
    this.totalBuyNetTarget.textContent = formatCurrency(totalBuyNet)
    this.totalLeaseCostTarget.textContent = formatCurrency(totalLeaseCost)
    this.savingsAmountTarget.textContent = formatCurrency(savingsAmount)
    this.recommendationTarget.textContent = rec
  }

  clearResults() {
    this.buyMonthlyPaymentTarget.textContent = "$0.00"
    this.totalBuyCostTarget.textContent = "$0.00"
    this.totalBuyNetTarget.textContent = "$0.00"
    this.totalLeaseCostTarget.textContent = "$0.00"
    this.savingsAmountTarget.textContent = "$0.00"
    this.recommendationTarget.textContent = "\u2014"
  }

  copy() {
    const text = `Lease vs Buy Calculator Results\nBuy Monthly Payment: ${this.buyMonthlyPaymentTarget.textContent}\nTotal Buy Cost: ${this.totalBuyCostTarget.textContent}\nTotal Buy Net (minus resale): ${this.totalBuyNetTarget.textContent}\nTotal Lease Cost: ${this.totalLeaseCostTarget.textContent}\nSavings: ${this.savingsAmountTarget.textContent}\nRecommendation: ${this.recommendationTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
