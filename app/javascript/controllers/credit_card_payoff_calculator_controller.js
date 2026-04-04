import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "balance", "apr", "monthlyPayment",
    "monthsToPayoff", "yearsToPayoff", "totalInterest", "totalPaid", "payoffDate",
    "scheduleBody", "scheduleSection"
  ]

  calculate() {
    const balance = parseFloat(this.balanceTarget.value) || 0
    const apr = parseFloat(this.aprTarget.value) / 100 || 0
    const monthlyPayment = parseFloat(this.monthlyPaymentTarget.value) || 0

    if (balance <= 0 || monthlyPayment <= 0 || apr < 0) {
      this.clearResults()
      return
    }

    const monthlyRate = apr / 12
    let remaining = balance
    let totalInterest = 0
    let months = 0
    const schedule = []
    const maxMonths = 1200

    while (remaining > 0.01 && months < maxMonths) {
      const interestCharge = remaining * monthlyRate
      const payment = Math.min(monthlyPayment, remaining + interestCharge)
      const principalPaid = payment - interestCharge

      if (principalPaid <= 0 && months > 0) {
        this.monthsToPayoffTarget.textContent = "Never"
        this.yearsToPayoffTarget.textContent = "N/A"
        this.totalInterestTarget.textContent = "Payment too low"
        this.totalPaidTarget.textContent = "N/A"
        this.payoffDateTarget.textContent = "N/A"
        this.scheduleBodyTarget.innerHTML = ""
        return
      }

      remaining -= principalPaid
      if (remaining < 0.01) remaining = 0
      totalInterest += interestCharge
      months++

      schedule.push({
        month: months,
        payment: payment,
        principal: principalPaid,
        interest: interestCharge,
        balance: remaining
      })
    }

    const totalPaid = balance + totalInterest
    const now = new Date()
    const payoffDate = new Date(now.getFullYear(), now.getMonth() + months, 1)
    const payoffDateStr = payoffDate.toLocaleDateString("en-US", { month: "long", year: "numeric" })

    this.monthsToPayoffTarget.textContent = months
    this.yearsToPayoffTarget.textContent = (months / 12).toFixed(1)
    this.totalInterestTarget.textContent = this.formatCurrency(totalInterest)
    this.totalPaidTarget.textContent = this.formatCurrency(totalPaid)
    this.payoffDateTarget.textContent = payoffDateStr

    this.renderSchedule(schedule)
  }

  renderSchedule(schedule) {
    let html = ""
    for (const row of schedule) {
      html += `
        <tr class="border-b border-gray-100 dark:border-gray-800">
          <td class="py-2 pr-3 text-sm text-gray-600 dark:text-gray-400">${row.month}</td>
          <td class="py-2 pr-3 text-sm text-right text-gray-700 dark:text-gray-300">${this.formatCurrency(row.payment)}</td>
          <td class="py-2 pr-3 text-sm text-right text-gray-700 dark:text-gray-300">${this.formatCurrency(row.principal)}</td>
          <td class="py-2 pr-3 text-sm text-right text-gray-700 dark:text-gray-300">${this.formatCurrency(row.interest)}</td>
          <td class="py-2 text-sm text-right font-semibold text-gray-900 dark:text-white">${this.formatCurrency(row.balance)}</td>
        </tr>`
    }
    this.scheduleBodyTarget.innerHTML = html
  }

  toggleSchedule() {
    this.scheduleSectionTarget.classList.toggle("hidden")
  }

  clearResults() {
    this.monthsToPayoffTarget.textContent = "0"
    this.yearsToPayoffTarget.textContent = "0.0"
    this.totalInterestTarget.textContent = "$0.00"
    this.totalPaidTarget.textContent = "$0.00"
    this.payoffDateTarget.textContent = "--"
    this.scheduleBodyTarget.innerHTML = ""
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Months to Payoff: ${this.monthsToPayoffTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}\nTotal Paid: ${this.totalPaidTarget.textContent}\nPayoff Date: ${this.payoffDateTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
