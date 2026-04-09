import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["subscriptionRows", "resultTotalMonthly", "resultTotalAnnual",
                     "resultCount", "resultAverage", "resultMostExpensive",
                     "breakdownBody"]

  connect() {
    this.rowCount = this.subscriptionRowsTarget.querySelectorAll("[data-sub-row]").length
    this.calculate()
  }

  addRow() {
    if (this.rowCount >= 15) return
    this.rowCount++
    const row = document.createElement("div")
    row.setAttribute("data-sub-row", "")
    row.className = "grid grid-cols-12 gap-2 items-center"
    row.innerHTML = `
      <input type="text" data-field="name" placeholder="Subscription ${this.rowCount}" class="col-span-4 text-sm" data-action="input->subscription-cost-calculator#calculate">
      <input type="number" data-field="cost" placeholder="Cost" class="col-span-3 text-sm" min="0" step="0.01" data-action="input->subscription-cost-calculator#calculate">
      <select data-field="frequency" class="col-span-3 text-sm" data-action="change->subscription-cost-calculator#calculate">
        <option value="monthly">Monthly</option>
        <option value="yearly">Yearly</option>
        <option value="weekly">Weekly</option>
      </select>
      <button type="button" data-action="click->subscription-cost-calculator#removeRow" class="col-span-2 text-red-500 hover:text-red-700 text-sm font-medium text-center">&times;</button>
    `
    this.subscriptionRowsTarget.appendChild(row)
  }

  removeRow(event) {
    const row = event.target.closest("[data-sub-row]")
    if (this.subscriptionRowsTarget.querySelectorAll("[data-sub-row]").length > 1) {
      row.remove()
      this.rowCount--
      this.calculate()
    }
  }

  calculate() {
    const rows = this.subscriptionRowsTarget.querySelectorAll("[data-sub-row]")
    const multipliers = { weekly: 4.33, monthly: 1, yearly: 1 / 12 }
    const subs = []
    let totalMonthly = 0

    rows.forEach(row => {
      const name = row.querySelector("[data-field='name']").value || "Unnamed"
      const cost = parseFloat(row.querySelector("[data-field='cost']").value) || 0
      const frequency = row.querySelector("[data-field='frequency']").value || "monthly"

      const monthly = cost * (multipliers[frequency] || 1)
      totalMonthly += monthly

      if (cost > 0) {
        subs.push({ name, cost, frequency, monthly })
      }
    })

    const totalAnnual = totalMonthly * 12
    const count = subs.length
    const average = count > 0 ? totalMonthly / count : 0
    const mostExpensive = subs.length > 0 ? subs.reduce((a, b) => a.monthly > b.monthly ? a : b) : null

    this.resultTotalMonthlyTarget.textContent = this.fmt(totalMonthly)
    this.resultTotalAnnualTarget.textContent = this.fmt(totalAnnual)
    this.resultCountTarget.textContent = count
    this.resultAverageTarget.textContent = this.fmt(average)
    this.resultMostExpensiveTarget.textContent = mostExpensive ? `${this.escapeHtml(mostExpensive.name)} (${this.fmt(mostExpensive.monthly)}/mo)` : "N/A"

    this.breakdownBodyTarget.innerHTML = subs.map(s =>
      `<tr class="border-b border-gray-100 dark:border-gray-800">
        <td class="py-2 text-sm text-gray-700 dark:text-gray-300">${this.escapeHtml(s.name)}</td>
        <td class="py-2 text-sm text-right text-gray-600 dark:text-gray-400">${this.fmt(s.cost)}/${s.frequency}</td>
        <td class="py-2 text-sm text-right font-medium text-blue-600 dark:text-blue-400">${this.fmt(s.monthly)}/mo</td>
      </tr>`
    ).join("")
  }

  fmt(n) {
    return "$" + Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }

  copy() {
    const lines = [
      `Total Monthly: ${this.resultTotalMonthlyTarget.textContent}`,
      `Total Annual: ${this.resultTotalAnnualTarget.textContent}`,
      `Subscriptions: ${this.resultCountTarget.textContent}`,
      `Average: ${this.resultAverageTarget.textContent}`,
      `Most Expensive: ${this.resultMostExpensiveTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
