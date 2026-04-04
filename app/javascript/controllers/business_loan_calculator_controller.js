import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "amount", "rate", "years", "originationFee",
    "monthlyPayment", "totalInterest", "totalPaid", "totalCost",
    "originationFeeAmount", "effectiveAPR", "numPayments"
  ]

  calculate() {
    const amount = parseFloat(this.amountTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100
    const years = parseInt(this.yearsTarget.value) || 0
    const originationFeePercent = parseFloat(this.originationFeeTarget.value) / 100 || 0

    if (amount <= 0 || years <= 0 || annualRate < 0) {
      this.clearResults()
      return
    }

    const monthlyRate = annualRate / 12
    const numPayments = years * 12
    let monthlyPayment

    if (monthlyRate === 0) {
      monthlyPayment = amount / numPayments
    } else {
      monthlyPayment = amount * (monthlyRate * Math.pow(1 + monthlyRate, numPayments)) /
                        (Math.pow(1 + monthlyRate, numPayments) - 1)
    }

    const totalPaid = monthlyPayment * numPayments
    const totalInterest = totalPaid - amount
    const originationFee = amount * originationFeePercent
    const totalCost = totalPaid + originationFee

    // Effective APR via Newton's method
    const netProceeds = amount - originationFee
    const effectiveAPR = this.computeEffectiveAPR(netProceeds, monthlyPayment, numPayments, monthlyRate)

    this.monthlyPaymentTarget.textContent = this.formatCurrency(monthlyPayment)
    this.totalInterestTarget.textContent = this.formatCurrency(totalInterest)
    this.totalPaidTarget.textContent = this.formatCurrency(totalPaid)
    this.totalCostTarget.textContent = this.formatCurrency(totalCost)
    this.originationFeeAmountTarget.textContent = this.formatCurrency(originationFee)
    this.effectiveAPRTarget.textContent = effectiveAPR.toFixed(2) + "%"
    this.numPaymentsTarget.textContent = numPayments
  }

  computeEffectiveAPR(netProceeds, monthlyPayment, numPayments, initialRate) {
    if (netProceeds <= 0 || monthlyPayment <= 0) return 0

    let r = initialRate > 0 ? initialRate : 0.005

    for (let i = 0; i < 50; i++) {
      const pv = monthlyPayment * (1 - Math.pow(1 + r, -numPayments)) / r
      const f = pv - netProceeds

      const dpv = monthlyPayment * (
        numPayments * Math.pow(1 + r, -numPayments - 1) / r -
        (1 - Math.pow(1 + r, -numPayments)) / (r * r)
      )

      if (Math.abs(dpv) < 1e-15) break

      let rNew = r - f / dpv
      if (rNew <= 0) rNew = r / 2
      if (Math.abs(rNew - r) < 1e-10) break

      r = rNew
    }

    return r * 12 * 100
  }

  clearResults() {
    this.monthlyPaymentTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
    this.totalPaidTarget.textContent = "$0.00"
    this.totalCostTarget.textContent = "$0.00"
    this.originationFeeAmountTarget.textContent = "$0.00"
    this.effectiveAPRTarget.textContent = "0.00%"
    this.numPaymentsTarget.textContent = "0"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Monthly Payment: ${this.monthlyPaymentTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}\nTotal Cost (incl. fees): ${this.totalCostTarget.textContent}\nOrigination Fee: ${this.originationFeeAmountTarget.textContent}\nEffective APR: ${this.effectiveAPRTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
