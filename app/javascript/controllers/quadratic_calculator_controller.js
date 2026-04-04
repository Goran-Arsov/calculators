import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["a", "b", "c", "discriminant", "x1", "x2", "vertex"]

  calculate() {
    const a = parseFloat(this.aTarget.value)
    const b = parseFloat(this.bTarget.value)
    const c = parseFloat(this.cTarget.value)

    if (isNaN(a) || isNaN(b) || isNaN(c)) {
      this.clearResults()
      return
    }

    if (a === 0) {
      this.discriminantTarget.textContent = "—"
      this.x1Target.textContent = "a cannot be 0"
      this.x2Target.textContent = "—"
      this.vertexTarget.textContent = "—"
      return
    }

    const discriminant = b * b - 4 * a * c
    this.discriminantTarget.textContent = this.fmt(discriminant)

    if (discriminant >= 0) {
      const sqrtD = Math.sqrt(discriminant)
      const x1 = (-b + sqrtD) / (2 * a)
      const x2 = (-b - sqrtD) / (2 * a)
      this.x1Target.textContent = this.fmt(x1)
      this.x2Target.textContent = this.fmt(x2)
    } else {
      const realPart = -b / (2 * a)
      const imagPart = Math.sqrt(Math.abs(discriminant)) / (2 * a)
      const real = this.fmt(realPart)
      const imag = this.fmt(Math.abs(imagPart))
      this.x1Target.textContent = `${real} + ${imag}i`
      this.x2Target.textContent = `${real} - ${imag}i`
    }

    const vertexX = -b / (2 * a)
    const vertexY = a * vertexX * vertexX + b * vertexX + c
    this.vertexTarget.textContent = `(${this.fmt(vertexX)}, ${this.fmt(vertexY)})`
  }

  clearResults() {
    this.discriminantTarget.textContent = "—"
    this.x1Target.textContent = "—"
    this.x2Target.textContent = "—"
    this.vertexTarget.textContent = "—"
  }

  fmt(n) {
    if (n >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const d = this.discriminantTarget.textContent
    const x1 = this.x1Target.textContent
    const x2 = this.x2Target.textContent
    const v = this.vertexTarget.textContent
    navigator.clipboard.writeText(`Discriminant: ${d}\nx1: ${x1}\nx2: ${x2}\nVertex: ${v}`)
  }
}
