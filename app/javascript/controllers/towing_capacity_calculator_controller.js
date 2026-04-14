import { Controller } from "@hotwired/stimulus"
import { LB_TO_KG } from "utils/units"

export default class extends Controller {
  static targets = [
    "gvwr", "curbWeight", "passengersWeight", "cargoWeight", "tongueWeightPct",
    "unitSystem",
    "gvwrLabel", "curbWeightLabel", "passengersWeightLabel", "cargoWeightLabel",
    "maxPayload", "currentPayload", "remainingPayload", "payloadPct",
    "maxTowing", "safeTowing", "maxTongueWeight", "gcwr"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = Math.round(toMetric ? n * LB_TO_KG : n / LB_TO_KG)
    }
    convert(this.gvwrTarget)
    convert(this.curbWeightTarget)
    convert(this.passengersWeightTarget)
    convert(this.cargoWeightTarget)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    const unit = metric ? "kg" : "lbs"
    if (this.hasGvwrLabelTarget) this.gvwrLabelTarget.textContent = `GVWR (${unit})`
    if (this.hasCurbWeightLabelTarget) this.curbWeightLabelTarget.textContent = `Curb Weight (${unit})`
    if (this.hasPassengersWeightLabelTarget) this.passengersWeightLabelTarget.textContent = `Passengers Weight (${unit})`
    if (this.hasCargoWeightLabelTarget) this.cargoWeightLabelTarget.textContent = `Cargo Weight (${unit})`
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const gvwrInput = parseFloat(this.gvwrTarget.value) || 0
    const curbInput = parseFloat(this.curbWeightTarget.value) || 0
    const passengersInput = parseFloat(this.passengersWeightTarget.value) || 0
    const cargoInput = parseFloat(this.cargoWeightTarget.value) || 0
    const tonguePct = (parseFloat(this.tongueWeightPctTarget.value) || 10) / 100

    if (gvwrInput <= 0 || curbInput <= 0 || curbInput >= gvwrInput) {
      this.clearResults()
      return
    }

    // Math internally in lbs
    const gvwr = metric ? gvwrInput / LB_TO_KG : gvwrInput
    const curb = metric ? curbInput / LB_TO_KG : curbInput
    const passengers = metric ? passengersInput / LB_TO_KG : passengersInput
    const cargo = metric ? cargoInput / LB_TO_KG : cargoInput

    const maxPayload = gvwr - curb
    const currentPayload = passengers + cargo
    const remainingPayload = maxPayload - currentPayload
    const payloadPct = maxPayload > 0 ? (currentPayload / maxPayload * 100) : 0

    const maxTowing = tonguePct > 0 ? Math.max(remainingPayload / tonguePct, 0) : 0
    const safeTowing = maxTowing * 0.80
    const maxTongue = maxTowing * tonguePct
    const gcwr = gvwr + maxTowing

    const unit = metric ? "kg" : "lbs"
    const toDisplay = (lb) => metric ? lb * LB_TO_KG : lb

    this.maxPayloadTarget.textContent = this.fmt(toDisplay(maxPayload)) + " " + unit
    this.currentPayloadTarget.textContent = this.fmt(toDisplay(currentPayload)) + " " + unit
    this.remainingPayloadTarget.textContent = this.fmt(toDisplay(remainingPayload)) + " " + unit
    this.payloadPctTarget.textContent = payloadPct.toFixed(1) + "%"
    this.maxTowingTarget.textContent = this.fmt(toDisplay(maxTowing)) + " " + unit
    this.safeTowingTarget.textContent = this.fmt(toDisplay(safeTowing)) + " " + unit
    this.maxTongueWeightTarget.textContent = this.fmt(toDisplay(maxTongue)) + " " + unit
    this.gcwrTarget.textContent = this.fmt(toDisplay(gcwr)) + " " + unit
  }

  clearResults() {
    const unit = this.unitSystemTarget.value === "metric" ? "kg" : "lbs"
    const zero = "0 " + unit
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
