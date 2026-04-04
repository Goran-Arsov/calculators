import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "cash", "investments", "realEstate", "vehicles", "otherAssets",
    "mortgage", "studentLoans", "autoLoans", "creditCards", "otherLiabilities",
    "totalAssets", "totalLiabilities", "netWorth", "assetToDebtRatio"
  ]

  calculate() {
    const cash = parseFloat(this.cashTarget.value) || 0
    const investments = parseFloat(this.investmentsTarget.value) || 0
    const realEstate = parseFloat(this.realEstateTarget.value) || 0
    const vehicles = parseFloat(this.vehiclesTarget.value) || 0
    const otherAssets = parseFloat(this.otherAssetsTarget.value) || 0

    const mortgage = parseFloat(this.mortgageTarget.value) || 0
    const studentLoans = parseFloat(this.studentLoansTarget.value) || 0
    const autoLoans = parseFloat(this.autoLoansTarget.value) || 0
    const creditCards = parseFloat(this.creditCardsTarget.value) || 0
    const otherLiabilities = parseFloat(this.otherLiabilitiesTarget.value) || 0

    const totalAssets = cash + investments + realEstate + vehicles + otherAssets
    const totalLiabilities = mortgage + studentLoans + autoLoans + creditCards + otherLiabilities
    const netWorth = totalAssets - totalLiabilities
    const assetToDebtRatio = totalLiabilities > 0 ? (totalAssets / totalLiabilities).toFixed(2) : totalAssets > 0 ? "∞" : "0.00"

    this.totalAssetsTarget.textContent = this.formatCurrency(totalAssets)
    this.totalLiabilitiesTarget.textContent = this.formatCurrency(totalLiabilities)
    this.netWorthTarget.textContent = this.formatCurrency(netWorth)
    this.assetToDebtRatioTarget.textContent = assetToDebtRatio
  }

  clearResults() {
    this.totalAssetsTarget.textContent = "$0.00"
    this.totalLiabilitiesTarget.textContent = "$0.00"
    this.netWorthTarget.textContent = "$0.00"
    this.assetToDebtRatioTarget.textContent = "0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Total Assets: ${this.totalAssetsTarget.textContent}\nTotal Liabilities: ${this.totalLiabilitiesTarget.textContent}\nNet Worth: ${this.netWorthTarget.textContent}\nAsset-to-Debt Ratio: ${this.assetToDebtRatioTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
