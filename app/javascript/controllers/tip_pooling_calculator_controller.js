import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"

export default class extends Controller {
  static targets = [
    "staffContainer", "totalTips", "method",
    "resultsBody", "averageTip", "staffCount"
  ]

  connect() {
    this.staffCount = 0
    this.addStaff()
    this.addStaff()
  }

  addStaff() {
    this.staffCount++
    const id = this.staffCount
    const html = `
      <div class="flex items-center gap-3" data-staff-row="${id}">
        <input type="text" data-field="name" data-staff-id="${id}" class="flex-1 text-sm" placeholder="Staff ${id}" data-action="input->tip-pooling-calculator#calculate">
        <input type="number" data-field="value" data-staff-id="${id}" class="w-24 text-sm" placeholder="Hours" step="0.5" min="0" data-action="input->tip-pooling-calculator#calculate">
        ${id > 2 ? `<button type="button" data-action="click->tip-pooling-calculator#removeStaff" data-staff-id="${id}" class="text-red-500 hover:text-red-700 text-sm px-2">x</button>` : '<div class="w-6"></div>'}
      </div>
    `
    this.staffContainerTarget.insertAdjacentHTML("beforeend", html)
  }

  removeStaff(event) {
    const id = event.currentTarget.dataset.staffId
    const row = this.staffContainerTarget.querySelector(`[data-staff-row="${id}"]`)
    if (row) row.remove()
    this.calculate()
  }

  calculate() {
    const totalTips = parseFloat(this.totalTipsTarget.value) || 0
    if (totalTips <= 0) {
      this.clearResults()
      return
    }

    const staff = []
    const rows = this.staffContainerTarget.querySelectorAll("[data-staff-row]")
    rows.forEach(row => {
      const name = row.querySelector('[data-field="name"]').value || "Staff"
      const value = parseFloat(row.querySelector('[data-field="value"]').value) || 0
      if (value > 0) {
        staff.push({ name, value })
      }
    })

    if (staff.length < 2) {
      this.clearResults()
      return
    }

    const totalValue = staff.reduce((s, m) => s + m.value, 0)
    let html = ""
    staff.forEach(m => {
      const share = (m.value / totalValue) * 100
      const tip = (totalTips * m.value) / totalValue
      html += `<tr class="border-t border-gray-200 dark:border-gray-700">
        <td class="py-2 text-sm">${m.name}</td>
        <td class="py-2 text-sm text-center">${m.value}</td>
        <td class="py-2 text-sm text-center">${share.toFixed(1)}%</td>
        <td class="py-2 text-sm text-right font-semibold">${formatCurrency(tip)}</td>
      </tr>`
    })

    this.resultsBodyTarget.innerHTML = html
    this.averageTipTarget.textContent = formatCurrency(totalTips / staff.length)
    this.staffCountTarget.textContent = staff.length
  }

  clearResults() {
    this.resultsBodyTarget.innerHTML = ""
    this.averageTipTarget.textContent = "$0.00"
    this.staffCountTarget.textContent = "0"
  }

  copy(event) {
    const rows = this.resultsBodyTarget.querySelectorAll("tr")
    let text = "Tip Distribution:\n"
    rows.forEach(row => {
      const cells = row.querySelectorAll("td")
      text += `${cells[0].textContent}: ${cells[3].textContent}\n`
    })
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
