import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["a", "b", "c", "resultDiscriminant", "resultX1", "resultX2", "resultVertex"]

  calculate() {
    const a = parseFloat(this.aTarget.value)
    const b = parseFloat(this.bTarget.value)
    const c = parseFloat(this.cTarget.value)

    if (isNaN(a) || isNaN(b) || isNaN(c)) {
      this.clearResults()
      return
    }

    if (a === 0) {
      this.resultDiscriminantTarget.textContent = "—"
      this.resultX1Target.textContent = "a cannot be 0"
      this.resultX2Target.textContent = "—"
      this.resultVertexTarget.textContent = "—"
      return
    }

    const discriminant = b * b - 4 * a * c
    this.resultDiscriminantTarget.textContent = this.fmt(discriminant)

    if (discriminant >= 0) {
      const sqrtD = Math.sqrt(discriminant)
      const x1 = (-b + sqrtD) / (2 * a)
      const x2 = (-b - sqrtD) / (2 * a)
      this.resultX1Target.textContent = this.fmt(x1)
      this.resultX2Target.textContent = this.fmt(x2)
    } else {
      const realPart = -b / (2 * a)
      const imagPart = Math.sqrt(Math.abs(discriminant)) / (2 * a)
      const real = this.fmt(realPart)
      const imag = this.fmt(Math.abs(imagPart))
      this.resultX1Target.textContent = `${real} + ${imag}i`
      this.resultX2Target.textContent = `${real} - ${imag}i`
    }

    const vertexX = -b / (2 * a)
    const vertexY = a * vertexX * vertexX + b * vertexX + c
    this.resultVertexTarget.textContent = `(${this.fmt(vertexX)}, ${this.fmt(vertexY)})`
  }

  clearResults() {
    this.resultDiscriminantTarget.textContent = "—"
    this.resultX1Target.textContent = "—"
    this.resultX2Target.textContent = "—"
    this.resultVertexTarget.textContent = "—"
  }

  fmt(n) {
    if (n >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const label = card.dataset.card
    const result = card.querySelector("[data-result]")
    navigator.clipboard.writeText(`${label}: ${result.textContent}`)
  }
}
