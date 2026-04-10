import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sides", "interiorAngle", "miterAngle", "cornerAngle"]

  calculate() {
    const sides = parseInt(this.sidesTarget.value) || 0

    if (sides < 3 || sides > 100) {
      this.clearResults()
      return
    }

    const interior = ((sides - 2) * 180) / sides
    const miter = 180 / sides
    const corner = 360 / sides

    this.interiorAngleTarget.textContent = `${interior.toFixed(2)}°`
    this.miterAngleTarget.textContent = `${miter.toFixed(2)}°`
    this.cornerAngleTarget.textContent = `${corner.toFixed(2)}°`
  }

  clearResults() {
    this.interiorAngleTarget.textContent = "0.00°"
    this.miterAngleTarget.textContent = "0.00°"
    this.cornerAngleTarget.textContent = "0.00°"
  }

  copy() {
    const text = `Miter Angle Estimate:\nSides: ${this.sidesTarget.value}\nInterior Angle: ${this.interiorAngleTarget.textContent}\nMiter Angle: ${this.miterAngleTarget.textContent}\nCorner Turn Angle: ${this.cornerAngleTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
