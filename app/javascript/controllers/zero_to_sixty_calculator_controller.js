import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "horsepower", "curbWeight", "drivetrain", "tireType",
    "zeroToSixty", "zeroToThirty", "quarterMileTime", "quarterMileSpeed", "powerToWeight"
  ]

  calculate() {
    const hp = parseFloat(this.horsepowerTarget.value) || 0
    const weight = parseFloat(this.curbWeightTarget.value) || 0
    const drivetrain = this.drivetrainTarget.value
    const tireType = this.tireTypeTarget.value

    if (hp <= 0 || weight <= 0) {
      this.clearResults()
      return
    }

    const pwr = weight / hp

    // Base 0-60 estimate
    let base = Math.pow(pwr, 0.75) * 0.95

    // Drivetrain factor
    const dtFactor = drivetrain === "awd" ? 0.90 : drivetrain === "fwd" ? 1.05 : 1.00
    // Tire factor
    const tireFactor = tireType === "summer" ? 0.95 : tireType === "performance" ? 0.90 : tireType === "winter" ? 1.10 : 1.00

    const zeroToSixty = base * dtFactor * tireFactor
    const zeroToThirty = zeroToSixty * 0.37

    // Quarter mile (Roger Huntington formula)
    const qmTime = 6.290 * Math.pow(pwr, 1/3)
    const qmSpeed = 224.0 / Math.pow(pwr, 1/3)

    this.zeroToSixtyTarget.textContent = zeroToSixty.toFixed(2) + "s"
    this.zeroToThirtyTarget.textContent = zeroToThirty.toFixed(2) + "s"
    this.quarterMileTimeTarget.textContent = qmTime.toFixed(2) + "s"
    this.quarterMileSpeedTarget.textContent = qmSpeed.toFixed(1) + " mph"
    this.powerToWeightTarget.textContent = pwr.toFixed(2) + " lbs/hp"
  }

  clearResults() {
    this.zeroToSixtyTarget.textContent = "0.00s"
    this.zeroToThirtyTarget.textContent = "0.00s"
    this.quarterMileTimeTarget.textContent = "0.00s"
    this.quarterMileSpeedTarget.textContent = "0.0 mph"
    this.powerToWeightTarget.textContent = "0.00 lbs/hp"
  }

  copy() {
    const text = `0-60 mph: ${this.zeroToSixtyTarget.textContent}\n0-30 mph: ${this.zeroToThirtyTarget.textContent}\n1/4 Mile: ${this.quarterMileTimeTarget.textContent} @ ${this.quarterMileSpeedTarget.textContent}\nPower-to-Weight: ${this.powerToWeightTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
