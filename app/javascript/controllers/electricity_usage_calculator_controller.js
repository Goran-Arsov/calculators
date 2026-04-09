import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["costPerKwh", "applianceRows", "resultTotalDailyKwh",
                     "resultTotalMonthlyKwh", "resultTotalMonthlyCost",
                     "breakdownBody"]

  connect() {
    this.rowCount = this.applianceRowsTarget.querySelectorAll("[data-appliance-row]").length
    this.calculate()
  }

  addRow() {
    if (this.rowCount >= 10) return
    this.rowCount++
    const row = document.createElement("div")
    row.setAttribute("data-appliance-row", "")
    row.className = "grid grid-cols-12 gap-2 items-center"
    row.innerHTML = `
      <input type="text" data-field="name" placeholder="Appliance ${this.rowCount}" class="col-span-4 text-sm" data-action="input->electricity-usage-calculator#calculate">
      <input type="number" data-field="watts" placeholder="Watts" class="col-span-3 text-sm" min="0" step="1" data-action="input->electricity-usage-calculator#calculate">
      <input type="number" data-field="hours" placeholder="Hrs/day" class="col-span-3 text-sm" min="0" max="24" step="0.5" data-action="input->electricity-usage-calculator#calculate">
      <button type="button" data-action="click->electricity-usage-calculator#removeRow" class="col-span-2 text-red-500 hover:text-red-700 text-sm font-medium text-center">&times;</button>
    `
    this.applianceRowsTarget.appendChild(row)
  }

  removeRow(event) {
    const row = event.target.closest("[data-appliance-row]")
    if (this.applianceRowsTarget.querySelectorAll("[data-appliance-row]").length > 1) {
      row.remove()
      this.rowCount--
      this.calculate()
    }
  }

  calculate() {
    const rate = parseFloat(this.costPerKwhTarget.value) || 0.12
    const rows = this.applianceRowsTarget.querySelectorAll("[data-appliance-row]")
    let totalDailyKwh = 0
    let totalMonthlyKwh = 0
    let totalMonthlyCost = 0
    const breakdown = []

    rows.forEach(row => {
      const name = row.querySelector("[data-field='name']").value || "Unnamed"
      const watts = parseFloat(row.querySelector("[data-field='watts']").value) || 0
      const hours = parseFloat(row.querySelector("[data-field='hours']").value) || 0

      const dailyKwh = (watts * hours) / 1000
      const monthlyKwh = dailyKwh * 30
      const monthlyCost = monthlyKwh * rate

      totalDailyKwh += dailyKwh
      totalMonthlyKwh += monthlyKwh
      totalMonthlyCost += monthlyCost

      if (watts > 0 && hours > 0) {
        breakdown.push({ name, dailyKwh, monthlyKwh, monthlyCost })
      }
    })

    this.resultTotalDailyKwhTarget.textContent = totalDailyKwh.toFixed(3)
    this.resultTotalMonthlyKwhTarget.textContent = totalMonthlyKwh.toFixed(2)
    this.resultTotalMonthlyCostTarget.textContent = this.fmt(totalMonthlyCost)

    this.breakdownBodyTarget.innerHTML = breakdown.map(a =>
      `<tr class="border-b border-gray-100 dark:border-gray-800">
        <td class="py-2 text-sm text-gray-700 dark:text-gray-300">${this.escapeHtml(a.name)}</td>
        <td class="py-2 text-sm text-right text-gray-600 dark:text-gray-400">${a.dailyKwh.toFixed(3)}</td>
        <td class="py-2 text-sm text-right text-gray-600 dark:text-gray-400">${a.monthlyKwh.toFixed(2)}</td>
        <td class="py-2 text-sm text-right font-medium text-blue-600 dark:text-blue-400">${this.fmt(a.monthlyCost)}</td>
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
      `Total Daily kWh: ${this.resultTotalDailyKwhTarget.textContent}`,
      `Total Monthly kWh: ${this.resultTotalMonthlyKwhTarget.textContent}`,
      `Total Monthly Cost: ${this.resultTotalMonthlyCostTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
