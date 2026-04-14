import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "cashBalance", "monthlyBurn", "monthlyRevenue", "revenueGrowth",
    "netBurn", "dailyBurn", "runwayMonths", "zeroCashDate", "profitStatus"
  ]

  connect() {
    prefillFromUrl(this, {
      cashBalance: "cashBalance", monthlyBurn: "monthlyBurn",
      monthlyRevenue: "monthlyRevenue", revenueGrowth: "revenueGrowth"
    })
    this.calculate()
  }

  calculate() {
    const cashBalance = parseFloat(this.cashBalanceTarget.value) || 0
    const monthlyBurn = parseFloat(this.monthlyBurnTarget.value) || 0
    const monthlyRevenue = parseFloat(this.monthlyRevenueTarget.value) || 0
    const revenueGrowth = parseFloat(this.revenueGrowthTarget.value) / 100 || 0

    if (cashBalance <= 0 || monthlyBurn <= 0) {
      this.clearResults()
      return
    }

    const netBurn = monthlyBurn - monthlyRevenue
    const dailyBurn = netBurn / 30

    let runwayMonths
    if (revenueGrowth > 0 && monthlyRevenue > 0) {
      runwayMonths = this.calculateRunwayWithGrowth(cashBalance, monthlyBurn, monthlyRevenue, revenueGrowth)
    } else {
      runwayMonths = netBurn > 0 ? Math.floor(cashBalance / netBurn) : null
    }

    this.netBurnTarget.textContent = formatCurrency(netBurn)
    this.dailyBurnTarget.textContent = formatCurrency(dailyBurn)

    if (runwayMonths === null) {
      this.runwayMonthsTarget.textContent = "Infinite"
      this.zeroCashDateTarget.textContent = "N/A"
      this.profitStatusTarget.textContent = "Profitable / Sustainable"
      this.profitStatusTarget.classList.remove("text-red-600")
      this.profitStatusTarget.classList.add("text-green-600")
    } else {
      this.runwayMonthsTarget.textContent = `${runwayMonths} months`
      const zeroDate = new Date()
      zeroDate.setMonth(zeroDate.getMonth() + runwayMonths)
      this.zeroCashDateTarget.textContent = zeroDate.toLocaleDateString("en-US", { year: "numeric", month: "long" })

      if (runwayMonths < 6) {
        this.profitStatusTarget.textContent = "Critical - Less than 6 months"
        this.profitStatusTarget.classList.remove("text-green-600")
        this.profitStatusTarget.classList.add("text-red-600")
      } else if (runwayMonths < 12) {
        this.profitStatusTarget.textContent = "Caution - Less than 12 months"
        this.profitStatusTarget.classList.remove("text-green-600", "text-red-600")
        this.profitStatusTarget.classList.add("text-yellow-600")
      } else {
        this.profitStatusTarget.textContent = "Healthy runway"
        this.profitStatusTarget.classList.remove("text-red-600", "text-yellow-600")
        this.profitStatusTarget.classList.add("text-green-600")
      }
    }
  }

  calculateRunwayWithGrowth(cash, burn, revenue, growth) {
    let remaining = cash
    let rev = revenue
    for (let month = 1; month <= 120; month++) {
      rev *= (1 + growth)
      const net = burn - rev
      remaining -= net
      if (net <= 0 && month > 1) return null // Revenue exceeds burn
      if (remaining <= 0) return month
    }
    return null
  }

  clearResults() {
    this.netBurnTarget.textContent = "$0.00"
    this.dailyBurnTarget.textContent = "$0.00"
    this.runwayMonthsTarget.textContent = "0 months"
    this.zeroCashDateTarget.textContent = "--"
    this.profitStatusTarget.textContent = "--"
  }

  copy(event) {
    const text = `Net Burn: ${this.netBurnTarget.textContent}\nRunway: ${this.runwayMonthsTarget.textContent}\nZero Cash: ${this.zeroCashDateTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
