import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "courseRows", "resultWeeklyTotal", "resultDailyWeekdays",
    "resultDailyAllDays", "breakdownBody"
  ]

  static multipliers = { 1: 1.0, 2: 1.5, 3: 2.0, 4: 2.5, 5: 3.0 }

  connect() {
    this.rowCount = this.courseRowsTarget.querySelectorAll("[data-course-row]").length
    this.calculate()
  }

  addRow() {
    if (this.rowCount >= 8) return
    this.rowCount++
    const row = document.createElement("div")
    row.setAttribute("data-course-row", "")
    row.className = "grid grid-cols-12 gap-2 items-center"
    row.innerHTML = `
      <input type="text" data-field="name" placeholder="Course ${this.rowCount}" class="col-span-5 text-sm" data-action="input->study-time-calculator#calculate">
      <input type="number" data-field="credits" placeholder="Credits" class="col-span-3 text-sm" min="1" max="12" step="1" data-action="input->study-time-calculator#calculate">
      <select data-field="difficulty" class="col-span-3 text-sm" data-action="change->study-time-calculator#calculate">
        <option value="1">1 - Easy</option>
        <option value="2">2 - Moderate</option>
        <option value="3" selected>3 - Average</option>
        <option value="4">4 - Hard</option>
        <option value="5">5 - Very Hard</option>
      </select>
      <button type="button" data-action="click->study-time-calculator#removeRow" class="col-span-1 text-red-500 hover:text-red-700 text-sm font-medium text-center">&times;</button>
    `
    this.courseRowsTarget.appendChild(row)
  }

  removeRow(event) {
    const row = event.target.closest("[data-course-row]")
    if (this.courseRowsTarget.querySelectorAll("[data-course-row]").length > 1) {
      row.remove()
      this.rowCount--
      this.calculate()
    }
  }

  calculate() {
    const rows = this.courseRowsTarget.querySelectorAll("[data-course-row]")
    let weeklyTotal = 0
    const breakdown = []

    rows.forEach(row => {
      const name = row.querySelector("[data-field='name']").value || "Unnamed"
      const credits = parseFloat(row.querySelector("[data-field='credits']").value) || 0
      const difficulty = parseInt(row.querySelector("[data-field='difficulty']").value) || 3

      if (credits > 0) {
        const multiplier = this.constructor.multipliers[difficulty] || 2.0
        const inClass = credits * 1.0
        const study = credits * multiplier
        const total = inClass + study

        weeklyTotal += total
        breakdown.push({ name, credits, difficulty, inClass, study, total })
      }
    })

    const dailyWeekdays = weeklyTotal / 5
    const dailyAllDays = weeklyTotal / 7

    this.resultWeeklyTotalTarget.textContent = weeklyTotal.toFixed(1)
    this.resultDailyWeekdaysTarget.textContent = dailyWeekdays.toFixed(1)
    this.resultDailyAllDaysTarget.textContent = dailyAllDays.toFixed(1)

    if (this.hasBreakdownBodyTarget) {
      this.breakdownBodyTarget.innerHTML = breakdown.map(c =>
        `<tr class="border-b border-gray-100 dark:border-gray-800">
          <td class="py-2 text-sm text-gray-700 dark:text-gray-300">${this.escapeHtml(c.name)}</td>
          <td class="py-2 text-sm text-right text-gray-600 dark:text-gray-400">${c.credits}</td>
          <td class="py-2 text-sm text-right text-gray-600 dark:text-gray-400">${c.difficulty}/5</td>
          <td class="py-2 text-sm text-right text-gray-600 dark:text-gray-400">${c.inClass.toFixed(1)}h</td>
          <td class="py-2 text-sm text-right text-gray-600 dark:text-gray-400">${c.study.toFixed(1)}h</td>
          <td class="py-2 text-sm text-right font-medium text-blue-600 dark:text-blue-400">${c.total.toFixed(1)}h</td>
        </tr>`
      ).join("")
    }
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }

  copy() {
    const lines = [
      `Weekly Total Hours: ${this.resultWeeklyTotalTarget.textContent}`,
      `Daily Average (Weekdays): ${this.resultDailyWeekdaysTarget.textContent}`,
      `Daily Average (All Days): ${this.resultDailyAllDaysTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
