import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "income", "filingStatus",
    "totalTax", "effectiveRate", "marginalRate", "afterTaxIncome",
    "breakdownBody"
  ]

  static values = {
    brackets: { type: Object, default: {
      single: [
        { min: 0, max: 11600, rate: 0.10 },
        { min: 11601, max: 47150, rate: 0.12 },
        { min: 47151, max: 100525, rate: 0.22 },
        { min: 100526, max: 191950, rate: 0.24 },
        { min: 191951, max: 243725, rate: 0.32 },
        { min: 243726, max: 609350, rate: 0.35 },
        { min: 609351, max: Infinity, rate: 0.37 }
      ],
      married_filing_jointly: [
        { min: 0, max: 23200, rate: 0.10 },
        { min: 23201, max: 94300, rate: 0.12 },
        { min: 94301, max: 201050, rate: 0.22 },
        { min: 201051, max: 383900, rate: 0.24 },
        { min: 383901, max: 487450, rate: 0.32 },
        { min: 487451, max: 731200, rate: 0.35 },
        { min: 731201, max: Infinity, rate: 0.37 }
      ],
      married_filing_separately: [
        { min: 0, max: 11600, rate: 0.10 },
        { min: 11601, max: 47150, rate: 0.12 },
        { min: 47151, max: 100525, rate: 0.22 },
        { min: 100526, max: 191950, rate: 0.24 },
        { min: 191951, max: 243725, rate: 0.32 },
        { min: 243726, max: 609350, rate: 0.35 },
        { min: 609351, max: Infinity, rate: 0.37 }
      ],
      head_of_household: [
        { min: 0, max: 16550, rate: 0.10 },
        { min: 16551, max: 63100, rate: 0.12 },
        { min: 63101, max: 100500, rate: 0.22 },
        { min: 100501, max: 191950, rate: 0.24 },
        { min: 191951, max: 243700, rate: 0.32 },
        { min: 243701, max: 609350, rate: 0.35 },
        { min: 609351, max: Infinity, rate: 0.37 }
      ]
    }}
  }

  calculate() {
    const income = parseFloat(this.incomeTarget.value) || 0
    const filingStatus = this.filingStatusTarget.value

    if (income <= 0 || !filingStatus) {
      this.clearResults()
      return
    }

    const brackets = this.bracketsValue[filingStatus]
    if (!brackets) {
      this.clearResults()
      return
    }

    let remaining = income
    let totalTax = 0
    const breakdown = []

    for (const bracket of brackets) {
      if (remaining <= 0) break

      const bracketWidth = bracket.min === 0
        ? bracket.max + 1
        : (bracket.max === Infinity ? remaining : bracket.max - bracket.min + 1)

      const taxableInBracket = Math.min(remaining, bracketWidth)
      const taxInBracket = taxableInBracket * bracket.rate

      breakdown.push({
        rate: Math.round(bracket.rate * 100),
        rangeMin: bracket.min,
        rangeMax: bracket.max,
        taxableAmount: taxableInBracket,
        tax: taxInBracket
      })

      totalTax += taxInBracket
      remaining -= taxableInBracket
    }

    const effectiveRate = income > 0 ? (totalTax / income * 100) : 0
    let marginalRate = 10
    for (const bracket of brackets) {
      if (income <= bracket.max || bracket.max === Infinity) {
        marginalRate = Math.round(bracket.rate * 100)
        break
      }
    }

    this.totalTaxTarget.textContent = this.formatCurrency(totalTax)
    this.effectiveRateTarget.textContent = effectiveRate.toFixed(2) + "%"
    this.marginalRateTarget.textContent = marginalRate + "%"
    this.afterTaxIncomeTarget.textContent = this.formatCurrency(income - totalTax)

    this.renderBreakdown(breakdown.filter(b => b.taxableAmount > 0))
  }

  renderBreakdown(breakdown) {
    let html = ""
    for (const row of breakdown) {
      const rangeMax = row.rangeMax === Infinity ? "+" : this.formatCurrency(row.rangeMax)
      const rangeLabel = row.rangeMax === Infinity
        ? `${this.formatCurrency(row.rangeMin)}+`
        : `${this.formatCurrency(row.rangeMin)} – ${rangeMax}`
      html += `
        <tr class="border-b border-gray-100 dark:border-gray-800">
          <td class="py-2.5 pr-3 text-sm text-gray-600 dark:text-gray-400">${row.rate}%</td>
          <td class="py-2.5 pr-3 text-sm text-gray-600 dark:text-gray-400">${rangeLabel}</td>
          <td class="py-2.5 pr-3 text-sm text-right text-gray-700 dark:text-gray-300">${this.formatCurrency(row.taxableAmount)}</td>
          <td class="py-2.5 text-sm text-right font-semibold text-gray-900 dark:text-white">${this.formatCurrency(row.tax)}</td>
        </tr>`
    }
    this.breakdownBodyTarget.innerHTML = html
  }

  clearResults() {
    this.totalTaxTarget.textContent = "$0.00"
    this.effectiveRateTarget.textContent = "0.00%"
    this.marginalRateTarget.textContent = "0%"
    this.afterTaxIncomeTarget.textContent = "$0.00"
    this.breakdownBodyTarget.innerHTML = ""
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Total Tax: ${this.totalTaxTarget.textContent}\nEffective Rate: ${this.effectiveRateTarget.textContent}\nMarginal Rate: ${this.marginalRateTarget.textContent}\nAfter-Tax Income: ${this.afterTaxIncomeTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
