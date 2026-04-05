import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "principal", "rate", "years",
    "monthlyPayment", "totalPaid", "totalInterest", "numPayments",
    "scheduleBody", "scheduleContainer"
  ]

  calculate() {
    const principal = parseFloat(this.principalTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100
    const years = parseInt(this.yearsTarget.value) || 0

    if (principal <= 0 || years <= 0 || annualRate < 0) {
      this.clearResults()
      return
    }

    const monthlyRate = annualRate / 12
    const numPayments = years * 12
    let monthlyPayment

    if (monthlyRate === 0) {
      monthlyPayment = principal / numPayments
    } else {
      monthlyPayment = principal * (monthlyRate * Math.pow(1 + monthlyRate, numPayments)) /
                        (Math.pow(1 + monthlyRate, numPayments) - 1)
    }

    const totalPaid = monthlyPayment * numPayments
    const totalInterest = totalPaid - principal

    this.monthlyPaymentTarget.textContent = this.formatCurrency(monthlyPayment)
    this.totalPaidTarget.textContent = this.formatCurrency(totalPaid)
    this.totalInterestTarget.textContent = this.formatCurrency(totalInterest)
    this.numPaymentsTarget.textContent = numPayments

    // Build amortization schedule
    this.buildSchedule(principal, monthlyRate, monthlyPayment, numPayments)
  }

  buildSchedule(principal, monthlyRate, monthlyPayment, numPayments) {
    let balance = principal
    let html = ""

    for (let i = 1; i <= numPayments; i++) {
      const interest = balance * monthlyRate
      let principalPay = monthlyPayment - interest
      if (i === numPayments) {
        principalPay = balance
      }
      balance -= principalPay
      if (balance < 0.01) balance = 0

      html += `<tr class="border-b border-gray-100 dark:border-gray-800 text-sm">
        <td class="py-2 pr-3 text-gray-700 dark:text-gray-300">${i}</td>
        <td class="py-2 pr-3 text-right text-gray-700 dark:text-gray-300">${this.formatCurrency(monthlyPayment)}</td>
        <td class="py-2 pr-3 text-right text-gray-700 dark:text-gray-300">${this.formatCurrency(principalPay)}</td>
        <td class="py-2 pr-3 text-right text-gray-700 dark:text-gray-300">${this.formatCurrency(interest)}</td>
        <td class="py-2 text-right text-gray-700 dark:text-gray-300">${this.formatCurrency(balance)}</td>
      </tr>`
    }

    this.scheduleBodyTarget.innerHTML = html
    this.scheduleContainerTarget.classList.remove("hidden")
  }

  clearResults() {
    this.monthlyPaymentTarget.textContent = "$0.00"
    this.totalPaidTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
    this.numPaymentsTarget.textContent = "0"
    this.scheduleBodyTarget.innerHTML = ""
    this.scheduleContainerTarget.classList.add("hidden")
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Amortization Schedule Results\nMonthly Payment: ${this.monthlyPaymentTarget.textContent}\nTotal Paid: ${this.totalPaidTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}\nNumber of Payments: ${this.numPaymentsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
