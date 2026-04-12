import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "gvwr", "curbWeight", "passengersWeight", "cargoWeight", "tongueWeightPct",
    "maxPayload", "currentPayload", "remainingPayload", "payloadPct",
    "maxTowing", "safeTowing", "maxTongueWeight", "gcwr"
  ]

  calculate() {
    const gvwr = parseFloat(this.gvwrTarget.value) || 0
    const curb = parseFloat(this.curbWeightTarget.value) || 0
    const passengers = parseFloat(this.passengersWeightTarget.value) || 0
    const cargo = parseFloat(this.cargoWeightTarget.value) || 0
    const tonguePct = (parseFloat(this.tongueWeightPctTarget.value) || 10) / 100

    if (gvwr <= 0 || curb <= 0 || curb >= gvwr) {
      this.clearResults()
      return
    }

    const maxPayload = gvwr - curb
    const currentPayload = passengers + cargo
    const remainingPayload = maxPayload - currentPayload
    const payloadPct = maxPayload > 0 ? (currentPayload / maxPayload * 100) : 0

    const maxTowing = tonguePct > 0 ? Math.max(remainingPayload / tonguePct, 0) : 0
    const safeTowing = maxTowing * 0.80
    const maxTongue = maxTowing * tonguePct
    const gcwr = gvwr + maxTowing

    this.maxPayloadTarget.textContent = this.fmt(maxPayload) + " lbs"
    this.currentPayloadTarget.textContent = this.fmt(currentPayload) + " lbs"
    this.remainingPayloadTarget.textContent = this.fmt(remainingPayload) + " lbs"
    this.payloadPctTarget.textContent = payloadPct.toFixed(1) + "%"
    this.maxTowingTarget.textContent = this.fmt(maxTowing) + " lbs"
    this.safeTowingTarget.textContent = this.fmt(safeTowing) + " lbs"
    this.maxTongueWeightTarget.textContent = this.fmt(maxTongue) + " lbs"
    this.gcwrTarget.textContent = this.fmt(gcwr) + " lbs"
  }

  clearResults() {
    const zero = "0 lbs"
    this.maxPayloadTarget.textContent = zero
    this.currentPayloadTarget.textContent = zero
    this.remainingPayloadTarget.textContent = zero
    this.payloadPctTarget.textContent = "0.0%"
    this.maxTowingTarget.textContent = zero
    this.safeTowingTarget.textContent = zero
    this.maxTongueWeightTarget.textContent = zero
    this.gcwrTarget.textContent = zero
  }

  fmt(n) {
    return Math.round(n).toLocaleString("en-US")
  }

  copy() {
    const text = `Max Payload: ${this.maxPayloadTarget.textContent}\nRemaining Payload: ${this.remainingPayloadTarget.textContent}\nMax Towing: ${this.maxTowingTarget.textContent}\nSafe Towing (80%): ${this.safeTowingTarget.textContent}\nMax Tongue Weight: ${this.maxTongueWeightTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
