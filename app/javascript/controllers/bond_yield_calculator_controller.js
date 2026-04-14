import { Controller } from "@hotwired/stimulus"
import { formatCurrency, formatPercent } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "faceValue", "couponRate", "marketPrice", "yearsToMaturity", "paymentsPerYear",
    "currentYield", "ytm", "annualCoupon", "couponPayment", "bondStatus"
  ]

  connect() {
    prefillFromUrl(this, {
      faceValue: "faceValue", couponRate: "couponRate", marketPrice: "marketPrice",
      yearsToMaturity: "yearsToMaturity", paymentsPerYear: "paymentsPerYear"
    })
    this.calculate()
  }

  calculate() {
    const faceValue = parseFloat(this.faceValueTarget.value) || 0
    const couponRate = parseFloat(this.couponRateTarget.value) / 100 || 0
    const marketPrice = parseFloat(this.marketPriceTarget.value) || 0
    const yearsToMaturity = parseFloat(this.yearsToMaturityTarget.value) || 0
    const paymentsPerYear = parseInt(this.paymentsPerYearTarget.value) || 2

    if (faceValue <= 0 || marketPrice <= 0 || yearsToMaturity <= 0) {
      this.clearResults()
      return
    }

    const annualCoupon = faceValue * couponRate
    const couponPayment = annualCoupon / paymentsPerYear
    const currentYield = (annualCoupon / marketPrice) * 100

    // YTM via Newton's method
    const n = Math.floor(yearsToMaturity * paymentsPerYear)
    let ytmGuess = (couponPayment + (faceValue - marketPrice) / n) / ((faceValue + marketPrice) / 2)

    for (let i = 0; i < 100; i++) {
      const price = this.bondPrice(ytmGuess, couponPayment, n, faceValue)
      const dprice = this.bondPriceDerivative(ytmGuess, couponPayment, n, faceValue)
      if (Math.abs(dprice) < 1e-15) break
      const adj = (price - marketPrice) / dprice
      ytmGuess -= adj
      if (Math.abs(adj) < 1e-10) break
    }

    const ytm = ytmGuess * paymentsPerYear * 100

    this.currentYieldTarget.textContent = formatPercent(currentYield)
    this.ytmTarget.textContent = formatPercent(ytm)
    this.annualCouponTarget.textContent = formatCurrency(annualCoupon)
    this.couponPaymentTarget.textContent = formatCurrency(couponPayment)

    if (marketPrice > faceValue) {
      this.bondStatusTarget.textContent = "Premium Bond"
    } else if (marketPrice < faceValue) {
      this.bondStatusTarget.textContent = "Discount Bond"
    } else {
      this.bondStatusTarget.textContent = "Par Bond"
    }
  }

  bondPrice(r, coupon, n, face) {
    if (Math.abs(r) < 1e-15) return coupon * n + face
    const pvCoupons = coupon * (1 - Math.pow(1 + r, -n)) / r
    const pvFace = face / Math.pow(1 + r, n)
    return pvCoupons + pvFace
  }

  bondPriceDerivative(r, coupon, n, face) {
    const dr = 1e-8
    return (this.bondPrice(r + dr, coupon, n, face) - this.bondPrice(r - dr, coupon, n, face)) / (2 * dr)
  }

  clearResults() {
    this.currentYieldTarget.textContent = "0.00%"
    this.ytmTarget.textContent = "0.00%"
    this.annualCouponTarget.textContent = "$0.00"
    this.couponPaymentTarget.textContent = "$0.00"
    this.bondStatusTarget.textContent = "--"
  }

  copy(event) {
    const text = `Current Yield: ${this.currentYieldTarget.textContent}\nYield to Maturity: ${this.ytmTarget.textContent}\nAnnual Coupon: ${this.annualCouponTarget.textContent}\nCoupon Payment: ${this.couponPaymentTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
