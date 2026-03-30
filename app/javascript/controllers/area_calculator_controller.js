import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["shape", "length", "width", "base", "height", "radius", "base1", "base2", "semiMajor", "semiMinor",
                     "rectangleFields", "triangleFields", "circleFields", "trapezoidFields", "ellipseFields", "result"]

  connect() {
    this.updateFields()
  }

  updateFields() {
    const shape = this.shapeTarget.value
    const allFields = ["rectangle", "triangle", "circle", "trapezoid", "ellipse"]
    allFields.forEach(s => {
      const target = this[`${s}FieldsTarget`]
      if (target) target.classList.toggle("hidden", s !== shape)
    })
    this.calculate()
  }

  calculate() {
    const shape = this.shapeTarget.value
    let area

    switch (shape) {
      case "rectangle":
        const l = parseFloat(this.lengthTarget.value) || 0
        const w = parseFloat(this.widthTarget.value) || 0
        if (l <= 0 || w <= 0) { this.resultTarget.textContent = "0"; return }
        area = l * w
        break
      case "triangle":
        const b = parseFloat(this.baseTarget.value) || 0
        const h = parseFloat(this.heightTarget.value) || 0
        if (b <= 0 || h <= 0) { this.resultTarget.textContent = "0"; return }
        area = 0.5 * b * h
        break
      case "circle":
        const r = parseFloat(this.radiusTarget.value) || 0
        if (r <= 0) { this.resultTarget.textContent = "0"; return }
        area = Math.PI * r * r
        break
      case "trapezoid":
        const b1 = parseFloat(this.base1Target.value) || 0
        const b2 = parseFloat(this.base2Target.value) || 0
        const ht = parseFloat(this.heightTarget.value) || 0
        if (b1 <= 0 || b2 <= 0 || ht <= 0) { this.resultTarget.textContent = "0"; return }
        area = 0.5 * (b1 + b2) * ht
        break
      case "ellipse":
        const a = parseFloat(this.semiMajorTarget.value) || 0
        const bE = parseFloat(this.semiMinorTarget.value) || 0
        if (a <= 0 || bE <= 0) { this.resultTarget.textContent = "0"; return }
        area = Math.PI * a * bE
        break
    }

    this.resultTarget.textContent = area.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    navigator.clipboard.writeText(`Area: ${this.resultTarget.textContent}`)
  }
}
