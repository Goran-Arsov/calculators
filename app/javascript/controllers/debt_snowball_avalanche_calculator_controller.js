import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"

export default class extends Controller {
  static targets = [
    "debtsContainer", "extraPayment",
    "snowballMonths", "snowballInterest", "snowballTotal",
    "avalancheMonths", "avalancheInterest", "avalancheTotal",
    "interestSaved", "monthsSaved", "recommendation"
  ]

  connect() {
    this.debtCount = 0
    this.addDebt()
    this.addDebt()
  }

  addDebt() {
    this.debtCount++
    const id = this.debtCount
    const html = `
      <div class="p-4 bg-gray-50 dark:bg-gray-800 rounded-xl space-y-3" data-debt-row="${id}">
        <div class="flex justify-between items-center">
          <span class="text-sm font-semibold text-gray-700 dark:text-gray-300">Debt ${id}</span>
          ${id > 2 ? `<button type="button" data-action="click->debt-snowball-avalanche-calculator#removeDebt" data-debt-id="${id}" class="text-red-500 hover:text-red-700 text-sm">Remove</button>` : ''}
        </div>
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Name</label>
            <input type="text" data-field="name" data-debt-id="${id}" class="w-full text-sm" placeholder="Credit Card" data-action="input->debt-snowball-avalanche-calculator#calculate">
          </div>
          <div>
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Balance ($)</label>
            <input type="number" data-field="balance" data-debt-id="${id}" class="w-full text-sm" placeholder="5000" step="any" min="0" data-action="input->debt-snowball-avalanche-calculator#calculate">
          </div>
          <div>
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Interest Rate (%)</label>
            <input type="number" data-field="rate" data-debt-id="${id}" class="w-full text-sm" placeholder="18" step="0.01" min="0" data-action="input->debt-snowball-avalanche-calculator#calculate">
          </div>
          <div>
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Min Payment ($)</label>
            <input type="number" data-field="minimum" data-debt-id="${id}" class="w-full text-sm" placeholder="100" step="any" min="0" data-action="input->debt-snowball-avalanche-calculator#calculate">
          </div>
        </div>
      </div>
    `
    this.debtsContainerTarget.insertAdjacentHTML("beforeend", html)
  }

  removeDebt(event) {
    const id = event.currentTarget.dataset.debtId
    const row = this.debtsContainerTarget.querySelector(`[data-debt-row="${id}"]`)
    if (row) row.remove()
    this.calculate()
  }

  getDebts() {
    const debts = []
    const rows = this.debtsContainerTarget.querySelectorAll("[data-debt-row]")
    rows.forEach(row => {
      const name = row.querySelector('[data-field="name"]').value || "Debt"
      const balance = parseFloat(row.querySelector('[data-field="balance"]').value) || 0
      const rate = parseFloat(row.querySelector('[data-field="rate"]').value) || 0
      const minimum = parseFloat(row.querySelector('[data-field="minimum"]').value) || 0
      if (balance > 0 && minimum > 0) {
        debts.push({ name, balance, rate: rate / 100, minimum })
      }
    })
    return debts
  }

  calculate() {
    const debts = this.getDebts()
    const extraPayment = parseFloat(this.extraPaymentTarget.value) || 0

    if (debts.length < 1) {
      this.clearResults()
      return
    }

    const snowball = this.simulate([...debts].sort((a, b) => a.balance - b.balance || b.rate - a.rate), extraPayment)
    const avalanche = this.simulate([...debts].sort((a, b) => b.rate - a.rate || a.balance - b.balance), extraPayment)

    this.snowballMonthsTarget.textContent = snowball.months
    this.snowballInterestTarget.textContent = formatCurrency(snowball.totalInterest)
    this.snowballTotalTarget.textContent = formatCurrency(snowball.totalPaid)

    this.avalancheMonthsTarget.textContent = avalanche.months
    this.avalancheInterestTarget.textContent = formatCurrency(avalanche.totalInterest)
    this.avalancheTotalTarget.textContent = formatCurrency(avalanche.totalPaid)

    const interestSaved = snowball.totalInterest - avalanche.totalInterest
    const monthsSaved = snowball.months - avalanche.months

    this.interestSavedTarget.textContent = formatCurrency(Math.abs(interestSaved))
    this.monthsSavedTarget.textContent = Math.abs(monthsSaved)

    if (interestSaved > 0) {
      this.recommendationTarget.textContent = "Avalanche saves you more money"
    } else if (interestSaved < 0) {
      this.recommendationTarget.textContent = "Snowball saves you more money"
    } else {
      this.recommendationTarget.textContent = "Both strategies cost the same"
    }
  }

  simulate(orderedDebts, extraPayment) {
    const balances = orderedDebts.map(d => d.balance)
    const rates = orderedDebts.map(d => d.rate)
    const minimums = orderedDebts.map(d => d.minimum)

    let totalInterest = 0
    let month = 0
    const maxMonths = 1200

    while (balances.some(b => b > 0) && month < maxMonths) {
      month++

      // Apply interest
      for (let i = 0; i < balances.length; i++) {
        if (balances[i] <= 0) continue
        const interest = balances[i] * rates[i] / 12
        totalInterest += interest
        balances[i] += interest
      }

      // Pay minimums
      for (let i = 0; i < balances.length; i++) {
        if (balances[i] <= 0) continue
        const payment = Math.min(minimums[i], balances[i])
        balances[i] -= payment
      }

      // Apply extra to first non-zero
      let extra = extraPayment
      for (let i = 0; i < balances.length; i++) {
        if (extra <= 0) break
        if (balances[i] <= 0) continue
        const payment = Math.min(extra, balances[i])
        balances[i] -= payment
        extra -= payment
      }
    }

    const totalOriginal = orderedDebts.reduce((s, d) => s + d.balance, 0)
    return {
      months: month,
      totalInterest: totalInterest,
      totalPaid: totalOriginal + totalInterest
    }
  }

  clearResults() {
    this.snowballMonthsTarget.textContent = "0"
    this.snowballInterestTarget.textContent = "$0.00"
    this.snowballTotalTarget.textContent = "$0.00"
    this.avalancheMonthsTarget.textContent = "0"
    this.avalancheInterestTarget.textContent = "$0.00"
    this.avalancheTotalTarget.textContent = "$0.00"
    this.interestSavedTarget.textContent = "$0.00"
    this.monthsSavedTarget.textContent = "0"
    this.recommendationTarget.textContent = "--"
  }

  copy(event) {
    const text = `Snowball: ${this.snowballMonthsTarget.textContent} months, ${this.snowballInterestTarget.textContent} interest\nAvalanche: ${this.avalancheMonthsTarget.textContent} months, ${this.avalancheInterestTarget.textContent} interest\nSavings: ${this.interestSavedTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
