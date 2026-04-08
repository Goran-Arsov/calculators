// Shared formatting utilities for calculator controllers.
// Import with: import { formatCurrency, formatNumber, formatPercent } from "utils/formatting"

const currencyFormatter = new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })
const percentFormatter = new Intl.NumberFormat("en-US", { style: "percent", minimumFractionDigits: 2, maximumFractionDigits: 2 })

export function formatCurrency(value) {
  return currencyFormatter.format(value)
}

export function formatNumber(value, decimals = 2) {
  return new Intl.NumberFormat("en-US", { minimumFractionDigits: decimals, maximumFractionDigits: decimals }).format(value)
}

export function formatPercent(value) {
  return percentFormatter.format(value / 100)
}
