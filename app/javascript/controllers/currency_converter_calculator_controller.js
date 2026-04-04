import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "amount", "fromCurrency", "toCurrency",
    "convertedAmount", "exchangeRate", "inverseRate", "disclaimer"
  ]

  static values = {
    rates: { type: Object, default: {
      USD: 1.0, EUR: 0.92, GBP: 0.79, JPY: 149.5, CAD: 1.36,
      AUD: 1.53, CHF: 0.88, CNY: 7.24, INR: 83.1, MXN: 17.15,
      BRL: 4.97, KRW: 1330, SEK: 10.42, NOK: 10.55, NZD: 1.64,
      SGD: 1.34, HKD: 7.82, TRY: 32.4, ZAR: 18.6, AED: 3.67
    }}
  }

  calculate() {
    const amount = parseFloat(this.amountTarget.value) || 0
    const fromCurrency = this.fromCurrencyTarget.value
    const toCurrency = this.toCurrencyTarget.value

    if (amount <= 0) {
      this.clearResults()
      return
    }

    const rates = this.ratesValue
    const fromRate = rates[fromCurrency]
    const toRate = rates[toCurrency]

    if (!fromRate || !toRate) {
      this.clearResults()
      return
    }

    const amountInUSD = amount / fromRate
    const convertedAmount = amountInUSD * toRate
    const exchangeRate = toRate / fromRate
    const inverseRate = fromRate / toRate

    this.convertedAmountTarget.textContent = this.formatNumber(convertedAmount, toCurrency)
    this.exchangeRateTarget.textContent = `1 ${fromCurrency} = ${exchangeRate.toFixed(6)} ${toCurrency}`
    this.inverseRateTarget.textContent = `1 ${toCurrency} = ${inverseRate.toFixed(6)} ${fromCurrency}`
  }

  swap() {
    const fromValue = this.fromCurrencyTarget.value
    const toValue = this.toCurrencyTarget.value
    this.fromCurrencyTarget.value = toValue
    this.toCurrencyTarget.value = fromValue
    this.calculate()
  }

  clearResults() {
    this.convertedAmountTarget.textContent = "0.00"
    this.exchangeRateTarget.textContent = "—"
    this.inverseRateTarget.textContent = "—"
  }

  formatNumber(value, currency) {
    // For currencies with very high values per USD (JPY, KRW), use fewer decimals
    const noDecimalCurrencies = ["JPY", "KRW"]
    const decimals = noDecimalCurrencies.includes(currency) ? 0 : 2
    return new Intl.NumberFormat("en-US", {
      minimumFractionDigits: decimals,
      maximumFractionDigits: decimals
    }).format(value)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const amount = this.amountTarget.value
    const from = this.fromCurrencyTarget.value
    const to = this.toCurrencyTarget.value
    const text = `${amount} ${from} = ${this.convertedAmountTarget.textContent} ${to}\n${this.exchangeRateTarget.textContent}\n${this.inverseRateTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
