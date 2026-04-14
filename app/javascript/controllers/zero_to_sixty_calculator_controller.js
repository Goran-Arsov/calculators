import { Controller } from "@hotwired/stimulus"
import { LB_TO_KG, MPH_TO_KMH } from "utils/units"

export default class extends Controller {
  static targets = [
    "horsepower", "curbWeight", "drivetrain", "tireType",
    "unitSystem", "curbWeightLabel",
    "zeroToSixtyHeading", "zeroToThirtyHeading",
    "zeroToSixty", "zeroToThirty", "quarterMileTime", "quarterMileSpeed", "powerToWeight"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const weight = parseFloat(this.curbWeightTarget.value)
    if (Number.isFinite(weight) && weight > 0) {
      this.curbWeightTarget.value = Math.round(toMetric ? weight * LB_TO_KG : weight / LB_TO_KG)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    if (this.hasCurbWeightLabelTarget) {
      this.curbWeightLabelTarget.textContent = metric ? "Curb Weight (kg)" : "Curb Weight (lbs)"
    }
    if (this.hasZeroToSixtyHeadingTarget) {
      this.zeroToSixtyHeadingTarget.textContent = metric ? "0-100 km/h" : "0-60 mph"
    }
    if (this.hasZeroToThirtyHeadingTarget) {
      this.zeroToThirtyHeadingTarget.textContent = metric ? "0-50 km/h" : "0-30 mph"
    }
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const hp = parseFloat(this.horsepowerTarget.value) || 0
    const weightInput = parseFloat(this.curbWeightTarget.value) || 0
    const drivetrain = this.drivetrainTarget.value
    const tireType = this.tireTypeTarget.value

    if (hp <= 0 || weightInput <= 0) {
      this.clearResults()
      return
    }

    // Math in imperial lbs
    const weight = metric ? weightInput / LB_TO_KG : weightInput
    const pwr = weight / hp // lbs/hp

    // Base 0-60 estimate
    let base = Math.pow(pwr, 0.75) * 0.95

    // Drivetrain factor
    const dtFactor = drivetrain === "awd" ? 0.90 : drivetrain === "fwd" ? 1.05 : 1.00
    // Tire factor
    const tireFactor = tireType === "summer" ? 0.95 : tireType === "performance" ? 0.90 : tireType === "winter" ? 1.10 : 1.00

    const zeroToSixty = base * dtFactor * tireFactor
    const zeroToThirty = zeroToSixty * 0.37

    // Quarter mile (Roger Huntington formula)
    const qmTime = 6.290 * Math.pow(pwr, 1 / 3)
    const qmSpeed = 224.0 / Math.pow(pwr, 1 / 3) // mph

    this.zeroToSixtyTarget.textContent = zeroToSixty.toFixed(2) + "s"
    this.zeroToThirtyTarget.textContent = zeroToThirty.toFixed(2) + "s"
    this.quarterMileTimeTarget.textContent = qmTime.toFixed(2) + "s"

    if (metric) {
      const qmSpeedKmh = qmSpeed * MPH_TO_KMH
      const pwrMetric = (weight * LB_TO_KG) / hp // kg/hp
      this.quarterMileSpeedTarget.textContent = qmSpeedKmh.toFixed(1) + " km/h"
      this.powerToWeightTarget.textContent = pwrMetric.toFixed(2) + " kg/hp"
    } else {
      this.quarterMileSpeedTarget.textContent = qmSpeed.toFixed(1) + " mph"
      this.powerToWeightTarget.textContent = pwr.toFixed(2) + " lbs/hp"
    }
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    this.zeroToSixtyTarget.textContent = "0.00s"
    this.zeroToThirtyTarget.textContent = "0.00s"
    this.quarterMileTimeTarget.textContent = "0.00s"
    this.quarterMileSpeedTarget.textContent = metric ? "0.0 km/h" : "0.0 mph"
    this.powerToWeightTarget.textContent = metric ? "0.00 kg/hp" : "0.00 lbs/hp"
  }

  copy() {
    const header0to60 = this.hasZeroToSixtyHeadingTarget ? this.zeroToSixtyHeadingTarget.textContent : "0-60 mph"
    const header0to30 = this.hasZeroToThirtyHeadingTarget ? this.zeroToThirtyHeadingTarget.textContent : "0-30 mph"
    const text = `${header0to60}: ${this.zeroToSixtyTarget.textContent}\n${header0to30}: ${this.zeroToThirtyTarget.textContent}\n1/4 Mile: ${this.quarterMileTimeTarget.textContent} @ ${this.quarterMileSpeedTarget.textContent}\nPower-to-Weight: ${this.powerToWeightTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
