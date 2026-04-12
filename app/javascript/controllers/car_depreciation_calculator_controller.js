import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "purchasePrice", "vehicleAge", "depreciationRate", "holdingYears",
    "currentValue", "futureValue", "totalDepreciation", "depreciationPct", "schedule"
  ]

  calculate() {
    const purchasePrice = parseFloat(this.purchasePriceTarget.value) || 0
    const vehicleAge = parseInt(this.vehicleAgeTarget.value) || 0
    const depRate = (parseFloat(this.depreciationRateTarget.value) || 15) / 100
    const holdingYears = parseInt(this.holdingYearsTarget.value) || 5

    if (purchasePrice <= 0 || holdingYears <= 0) {
      this.clearResults()
      return
    }

    const firstYearRate = vehicleAge === 0 ? 0.20 : depRate

    // Calculate current value
    let currentValue = purchasePrice
    if (vehicleAge > 0) {
      if (vehicleAge >= 1) currentValue *= (1 - firstYearRate)
      const remaining = Math.max(vehicleAge - 1, 0)
      if (remaining > 0) currentValue *= Math.pow(1 - depRate, remaining)
    }

    // Build schedule
    let value = currentValue
    let scheduleHtml = ""
    const totalYears = vehicleAge

    for (let i = 0; i < holdingYears; i++) {
      const yearNum = totalYears + i + 1
      const rate = (totalYears === 0 && i === 0) ? firstYearRate : depRate
      const dep = value * rate
      value -= dep
      scheduleHtml += `<tr class="border-b border-gray-100 dark:border-gray-800">
        <td class="py-2 px-3 text-sm">${yearNum}</td>
        <td class="py-2 px-3 text-sm">${this.fmt(value + dep)}</td>
        <td class="py-2 px-3 text-sm text-red-600 dark:text-red-400">-${this.fmt(dep)}</td>
        <td class="py-2 px-3 text-sm font-medium">${this.fmt(value)}</td>
      </tr>`
    }

    const futureValue = value
    const totalDep = currentValue - futureValue
    const depPct = currentValue > 0 ? (totalDep / currentValue * 100) : 0

    this.currentValueTarget.textContent = this.fmt(currentValue)
    this.futureValueTarget.textContent = this.fmt(futureValue)
    this.totalDepreciationTarget.textContent = this.fmt(totalDep)
    this.depreciationPctTarget.textContent = depPct.toFixed(1) + "%"
    this.scheduleTarget.innerHTML = scheduleHtml
  }

  clearResults() {
    this.currentValueTarget.textContent = "$0.00"
    this.futureValueTarget.textContent = "$0.00"
    this.totalDepreciationTarget.textContent = "$0.00"
    this.depreciationPctTarget.textContent = "0.0%"
    this.scheduleTarget.innerHTML = ""
  }

  fmt(n) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(n)
  }

  copy() {
    const text = `Current Value: ${this.currentValueTarget.textContent}\nFuture Value: ${this.futureValueTarget.textContent}\nTotal Depreciation: ${this.totalDepreciationTarget.textContent}\nDepreciation %: ${this.depreciationPctTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
