import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "monthlySubscriptions", "totalCustomers", "newCustomers",
    "churnedCustomers", "cac", "arpu",
    "mrr", "arr", "churnRate", "ltv", "ltvCacRatio",
    "cacPayback", "quickRatio", "healthStatus"
  ]

  connect() {
    if (prefillFromUrl(this, {
      monthlySubscriptions: "monthlySubscriptions", totalCustomers: "totalCustomers",
      newCustomers: "newCustomers", churnedCustomers: "churnedCustomers", cac: "cac"
    })) {
      this.calculate()
    }
  }

  calculate() {
    const mrr = parseFloat(this.monthlySubscriptionsTarget.value) || 0
    const totalCustomers = parseInt(this.totalCustomersTarget.value) || 0
    const newCustomers = parseInt(this.newCustomersTarget.value) || 0
    const churnedCustomers = parseInt(this.churnedCustomersTarget.value) || 0
    const cac = parseFloat(this.cacTarget.value) || 0
    const arpuInput = parseFloat(this.arpuTarget.value) || 0

    if (mrr <= 0 || totalCustomers <= 0) {
      this.clearResults()
      return
    }

    const arr = mrr * 12
    const churnRate = (churnedCustomers / totalCustomers) * 100
    const arpu = arpuInput > 0 ? arpuInput : mrr / totalCustomers

    const monthlyChurn = churnRate / 100
    const ltv = monthlyChurn > 0 ? arpu / monthlyChurn : 0
    const ltvCacRatio = cac > 0 ? ltv / cac : 0
    const cacPayback = arpu > 0 ? Math.ceil(cac / arpu) : 0

    // Quick Ratio
    const newMrr = arpu * newCustomers
    const churnedMrr = churnedCustomers > 0 && totalCustomers > 0 ? (mrr / totalCustomers) * churnedCustomers : 0
    const quickRatio = churnedMrr > 0 ? newMrr / churnedMrr : 0

    this.mrrTarget.textContent = formatCurrency(mrr)
    this.arrTarget.textContent = formatCurrency(arr)
    this.churnRateTarget.textContent = churnRate.toFixed(2) + "%"
    this.ltvTarget.textContent = formatCurrency(ltv)
    this.ltvCacRatioTarget.textContent = ltvCacRatio.toFixed(2) + "x"
    this.cacPaybackTarget.textContent = cacPayback + " months"
    this.quickRatioTarget.textContent = quickRatio.toFixed(2) + "x"

    // Health assessment
    if (ltvCacRatio >= 3 && churnRate <= 5 && quickRatio >= 4) {
      this.healthStatusTarget.textContent = "Excellent"
      this.healthStatusTarget.className = "text-xl font-bold text-green-600 dark:text-green-400"
    } else if (ltvCacRatio >= 1 && churnRate <= 10) {
      this.healthStatusTarget.textContent = "Good"
      this.healthStatusTarget.className = "text-xl font-bold text-blue-600 dark:text-blue-400"
    } else {
      this.healthStatusTarget.textContent = "Needs Attention"
      this.healthStatusTarget.className = "text-xl font-bold text-red-600 dark:text-red-400"
    }
  }

  clearResults() {
    this.mrrTarget.textContent = "$0.00"
    this.arrTarget.textContent = "$0.00"
    this.churnRateTarget.textContent = "0.00%"
    this.ltvTarget.textContent = "$0.00"
    this.ltvCacRatioTarget.textContent = "0.00x"
    this.cacPaybackTarget.textContent = "0 months"
    this.quickRatioTarget.textContent = "0.00x"
    this.healthStatusTarget.textContent = "--"
  }

  copy(event) {
    const text = `MRR: ${this.mrrTarget.textContent}\nARR: ${this.arrTarget.textContent}\nChurn Rate: ${this.churnRateTarget.textContent}\nLTV: ${this.ltvTarget.textContent}\nLTV:CAC Ratio: ${this.ltvCacRatioTarget.textContent}\nCAC Payback: ${this.cacPaybackTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
