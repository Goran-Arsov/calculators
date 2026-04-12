import { Controller } from "@hotwired/stimulus"

const BASE = { low: 215000, middle: 310000, high: 455000 }
const COL = { lcol: 0.82, mcol: 1.0, hcol: 1.28 }
const CATS = { Housing: 0.29, Food: 0.18, "Childcare/Education": 0.16, Transportation: 0.15, Healthcare: 0.09, Clothing: 0.06, Misc: 0.07 }
const DISCOUNT = 0.24

export default class extends Controller {
  static targets = ["income", "col", "kids", "resultTotal", "resultPerChild", "resultMonthly", "breakdownList"]

  connect() { this.calculate() }

  calculate() {
    const income = this.incomeTarget.value
    const col = this.colTarget.value
    const kids = parseInt(this.kidsTarget.value) || 1
    if (!BASE[income] || !COL[col]) { this.clear(); return }

    const perChild = BASE[income] * COL[col]
    let total = perChild
    for (let i = 1; i < kids; i++) total += perChild * (1 - DISCOUNT)

    this.resultTotalTarget.textContent = this.money(total)
    this.resultPerChildTarget.textContent = this.money(perChild)
    this.resultMonthlyTarget.textContent = this.money(perChild / 18 / 12)

    this.breakdownListTarget.innerHTML = Object.entries(CATS)
      .map(([k, v]) => `<li class="flex justify-between"><span>${k}</span><span class="font-bold">${this.money(perChild * v)}</span></li>`)
      .join("")
  }

  money(n) { return `$${Math.round(n).toLocaleString("en-US")}` }

  clear() {
    ["Total","PerChild","Monthly"].forEach(k => { this[`result${k}Target`].textContent = "—" })
    this.breakdownListTarget.innerHTML = ""
  }

  copy() {
    navigator.clipboard.writeText(`Cost of raising a child: ${this.resultTotalTarget.textContent}`)
  }
}
