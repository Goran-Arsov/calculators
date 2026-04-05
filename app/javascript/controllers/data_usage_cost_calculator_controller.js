import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "planSize", "planCost", "actualUsage", "overageRate",
    "costPerGb", "overageGb", "overageCost", "unusedGb",
    "unusedDataValue", "totalCost", "effectiveCostPerGb", "usagePercentage"
  ]

  calculate() {
    const planSize = parseFloat(this.planSizeTarget.value) || 0
    const planCost = parseFloat(this.planCostTarget.value) || 0
    const actualUsage = parseFloat(this.actualUsageTarget.value) || 0
    const overageRate = parseFloat(this.overageRateTarget.value) || 0

    if (planSize <= 0 || planCost <= 0 || actualUsage <= 0) {
      this.clearResults()
      return
    }

    const costPerGb = planCost / planSize
    const overageGb = Math.max(actualUsage - planSize, 0)
    const unusedGb = Math.max(planSize - actualUsage, 0)
    const overageCost = overageGb * overageRate
    const unusedDataValue = unusedGb * costPerGb
    const totalCost = planCost + overageCost
    const effectiveCostPerGb = totalCost / actualUsage
    const usagePercentage = (actualUsage / planSize) * 100

    this.costPerGbTarget.textContent = this.formatCurrency(costPerGb)
    this.overageGbTarget.textContent = this.formatNumber(overageGb) + " GB"
    this.overageCostTarget.textContent = this.formatCurrency(overageCost)
    this.unusedGbTarget.textContent = this.formatNumber(unusedGb) + " GB"
    this.unusedDataValueTarget.textContent = this.formatCurrency(unusedDataValue)
    this.totalCostTarget.textContent = this.formatCurrency(totalCost)
    this.effectiveCostPerGbTarget.textContent = this.formatCurrency(effectiveCostPerGb)
    this.usagePercentageTarget.textContent = this.formatNumber(usagePercentage) + "%"
  }

  clearResults() {
    ;["costPerGb", "overageCost", "unusedDataValue", "totalCost", "effectiveCostPerGb"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
    ;["overageGb", "unusedGb", "usagePercentage"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Cost per GB: ${this.costPerGbTarget.textContent}\nTotal cost: ${this.totalCostTarget.textContent}\nOverage cost: ${this.overageCostTarget.textContent}\nUnused data value: ${this.unusedDataValueTarget.textContent}\nUsage: ${this.usagePercentageTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  formatNumber(value) {
    return Number(value).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
