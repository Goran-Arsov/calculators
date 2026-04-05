import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalSpend", "leads", "qualifiedLeads", "totalVisitors",
    "resultCpl", "resultCpql", "resultQualRate", "resultConvRate"
  ]

  calculate() {
    const totalSpend = parseFloat(this.totalSpendTarget.value) || 0
    const leads = parseInt(this.leadsTarget.value) || 0
    const qualifiedLeads = this.hasQualifiedLeadsTarget ? (parseInt(this.qualifiedLeadsTarget.value) || 0) : 0
    const totalVisitors = this.hasTotalVisitorsTarget ? (parseInt(this.totalVisitorsTarget.value) || 0) : 0

    if (totalSpend <= 0 || leads <= 0) {
      this.clearResults()
      return
    }

    const cpl = totalSpend / leads
    this.resultCplTarget.textContent = "$" + this.formatCurrency(cpl)

    if (qualifiedLeads > 0 && qualifiedLeads <= leads) {
      const cpql = totalSpend / qualifiedLeads
      const qualRate = (qualifiedLeads / leads) * 100
      this.resultCpqlTarget.textContent = "$" + this.formatCurrency(cpql)
      this.resultQualRateTarget.textContent = this.fmt(qualRate) + "%"
    } else {
      this.resultCpqlTarget.textContent = "\u2014"
      this.resultQualRateTarget.textContent = "\u2014"
    }

    if (totalVisitors > 0) {
      const convRate = (leads / totalVisitors) * 100
      this.resultConvRateTarget.textContent = this.fmt(convRate) + "%"
    } else {
      this.resultConvRateTarget.textContent = "\u2014"
    }
  }

  clearResults() {
    this.resultCplTarget.textContent = "\u2014"
    this.resultCpqlTarget.textContent = "\u2014"
    this.resultQualRateTarget.textContent = "\u2014"
    this.resultConvRateTarget.textContent = "\u2014"
  }

  formatCurrency(n) {
    return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const cpl = this.resultCplTarget.textContent
    const cpql = this.resultCpqlTarget.textContent
    const qualRate = this.resultQualRateTarget.textContent
    const convRate = this.resultConvRateTarget.textContent
    const text = `Cost Per Lead: ${cpl}\nCost Per Qualified Lead: ${cpql}\nQualification Rate: ${qualRate}\nConversion Rate: ${convRate}`
    navigator.clipboard.writeText(text)
  }
}
