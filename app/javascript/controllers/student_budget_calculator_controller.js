import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "tuition", "roomAndBoard", "booksSupplies", "transportation", "personalExpenses",
    "financialAid", "workIncome", "otherScholarships",
    "resultTotalCost", "resultTotalAid", "resultAnnualGap",
    "resultMonthly12", "resultMonthly9", "breakdownBody"
  ]

  connect() {
    if (prefillFromUrl(this, {
      tuition: "tuition",
      room_and_board: "roomAndBoard",
      books_supplies: "booksSupplies",
      transportation: "transportation",
      personal_expenses: "personalExpenses",
      financial_aid: "financialAid",
      work_income: "workIncome",
      other_scholarships: "otherScholarships"
    })) {
      this.calculate()
    }
  }

  calculate() {
    const tuition = parseFloat(this.tuitionTarget.value) || 0
    const room = parseFloat(this.roomAndBoardTarget.value) || 0
    const books = parseFloat(this.booksSuppliesTarget.value) || 0
    const transport = parseFloat(this.transportationTarget.value) || 0
    const personal = parseFloat(this.personalExpensesTarget.value) || 0

    const aid = parseFloat(this.financialAidTarget.value) || 0
    const work = parseFloat(this.workIncomeTarget.value) || 0
    const scholarships = parseFloat(this.otherScholarshipsTarget.value) || 0

    const totalCost = tuition + room + books + transport + personal
    const totalAid = aid + work + scholarships
    const annualGap = totalCost - totalAid
    const monthly12 = annualGap / 12
    const monthly9 = annualGap / 9

    this.resultTotalCostTarget.textContent = this.fmt(totalCost)
    this.resultTotalAidTarget.textContent = this.fmt(totalAid)
    this.resultAnnualGapTarget.textContent = this.fmt(annualGap)
    this.resultMonthly12Target.textContent = this.fmt(monthly12)
    this.resultMonthly9Target.textContent = this.fmt(monthly9)

    const breakdown = [
      { name: "Tuition", amount: tuition },
      { name: "Room & Board", amount: room },
      { name: "Books & Supplies", amount: books },
      { name: "Transportation", amount: transport },
      { name: "Personal Expenses", amount: personal }
    ]

    if (this.hasBreakdownBodyTarget) {
      this.breakdownBodyTarget.innerHTML = breakdown.map(item => {
        const pct = totalCost > 0 ? ((item.amount / totalCost) * 100).toFixed(1) : "0.0"
        return `<tr class="border-b border-gray-100 dark:border-gray-800">
          <td class="py-2 text-sm text-gray-700 dark:text-gray-300">${item.name}</td>
          <td class="py-2 text-sm text-right text-gray-600 dark:text-gray-400">${this.fmt(item.amount)}</td>
          <td class="py-2 text-sm text-right font-medium text-blue-600 dark:text-blue-400">${pct}%</td>
        </tr>`
      }).join("")
    }
  }

  fmt(n) {
    return "$" + Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  copy() {
    const lines = [
      `Total Cost: ${this.resultTotalCostTarget.textContent}`,
      `Total Aid: ${this.resultTotalAidTarget.textContent}`,
      `Annual Gap: ${this.resultAnnualGapTarget.textContent}`,
      `Monthly (12-month): ${this.resultMonthly12Target.textContent}`,
      `Monthly (9-month): ${this.resultMonthly9Target.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
