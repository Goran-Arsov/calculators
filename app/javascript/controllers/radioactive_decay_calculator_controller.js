import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mode",
    "initialAmount", "halfLife", "time", "remainingAmount",
    "initialAmountGroup", "halfLifeGroup", "timeGroup", "remainingAmountGroup",
    "results",
    "resultRemaining", "resultDecayed", "resultPercentRemaining",
    "resultHalfLivesElapsed", "resultDecayConstant", "resultActivity", "resultTime", "resultHalfLife"
  ]

  connect() {
    this.updateFields()
  }

  updateFields() {
    const mode = this.modeTarget.value
    this.initialAmountGroupTarget.classList.remove("hidden")
    this.halfLifeGroupTarget.classList.toggle("hidden", mode === "find_half_life")
    this.timeGroupTarget.classList.toggle("hidden", mode === "find_time")
    this.remainingAmountGroupTarget.classList.toggle("hidden", mode === "find_remaining")
    this.resultsTarget.classList.add("hidden")
  }

  calculate() {
    const mode = this.modeTarget.value
    let N0, tHalf, t, N, lambda, activity, halfLivesElapsed

    if (mode === "find_remaining") {
      N0 = parseFloat(this.initialAmountTarget.value)
      tHalf = parseFloat(this.halfLifeTarget.value)
      t = parseFloat(this.timeTarget.value)
      if (isNaN(N0) || N0 <= 0 || isNaN(tHalf) || tHalf <= 0 || isNaN(t) || t < 0) { this.resultsTarget.classList.add("hidden"); return }
      halfLivesElapsed = t / tHalf
      N = N0 * Math.pow(0.5, halfLivesElapsed)
      lambda = Math.LN2 / tHalf
      activity = lambda * N
    } else if (mode === "find_time") {
      N0 = parseFloat(this.initialAmountTarget.value)
      N = parseFloat(this.remainingAmountTarget.value)
      tHalf = parseFloat(this.halfLifeTarget.value)
      if (isNaN(N0) || N0 <= 0 || isNaN(N) || N <= 0 || N >= N0 || isNaN(tHalf) || tHalf <= 0) { this.resultsTarget.classList.add("hidden"); return }
      t = tHalf * Math.log(N0 / N) / Math.LN2
      halfLivesElapsed = t / tHalf
      lambda = Math.LN2 / tHalf
      activity = lambda * N
    } else if (mode === "find_half_life") {
      N0 = parseFloat(this.initialAmountTarget.value)
      N = parseFloat(this.remainingAmountTarget.value)
      t = parseFloat(this.timeTarget.value)
      if (isNaN(N0) || N0 <= 0 || isNaN(N) || N <= 0 || N >= N0 || isNaN(t) || t <= 0) { this.resultsTarget.classList.add("hidden"); return }
      tHalf = t * Math.LN2 / Math.log(N0 / N)
      halfLivesElapsed = t / tHalf
      lambda = Math.LN2 / tHalf
      activity = lambda * N
    }

    const percentRemaining = (N / N0) * 100
    const decayed = N0 - N

    this.resultsTarget.classList.remove("hidden")
    this.resultRemainingTarget.textContent = this.fmt(N)
    this.resultDecayedTarget.textContent = this.fmt(decayed)
    this.resultPercentRemainingTarget.textContent = percentRemaining.toFixed(2) + "%"
    this.resultHalfLivesElapsedTarget.textContent = halfLivesElapsed.toFixed(4)
    this.resultDecayConstantTarget.textContent = this.fmtSci(lambda)
    this.resultActivityTarget.textContent = this.fmtSci(activity)
    this.resultTimeTarget.textContent = this.fmt(t)
    this.resultHalfLifeTarget.textContent = this.fmt(tHalf)
  }

  fmt(n) {
    const abs = Math.abs(n)
    if (abs >= 1e6) return n.toExponential(4)
    if (abs >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  fmtSci(n) {
    if (Math.abs(n) < 0.001 || Math.abs(n) >= 1e6) return n.toExponential(6)
    return n.toFixed(8).replace(/\.?0+$/, "")
  }

  copy() {
    const results = this.resultsTarget.querySelectorAll("[data-result]")
    const lines = Array.from(results).map(el => el.textContent)
    navigator.clipboard.writeText("Radioactive Decay: " + lines.join(" | "))
  }
}
