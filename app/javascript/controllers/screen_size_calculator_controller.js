import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "diagonal", "aspectWidth", "aspectHeight", "resH", "resV",
    "resultWidth", "resultHeight", "resultArea", "resultPpi",
    "resultAspect", "resultResolution"
  ]

  calculate() {
    const diagonal = parseFloat(this.diagonalTarget.value) || 0
    const aw = parseFloat(this.aspectWidthTarget.value) || 0
    const ah = parseFloat(this.aspectHeightTarget.value) || 0
    const resH = parseInt(this.resHTarget.value) || 0
    const resV = parseInt(this.resVTarget.value) || 0

    if (diagonal <= 0 || aw <= 0 || ah <= 0) return

    const ratio = aw / ah
    const height = diagonal / Math.sqrt(ratio * ratio + 1)
    const width = height * ratio
    const area = width * height

    this.resultWidthTarget.textContent = width.toFixed(2) + " in"
    this.resultHeightTarget.textContent = height.toFixed(2) + " in"
    this.resultAreaTarget.textContent = area.toFixed(2) + " sq in"
    this.resultAspectTarget.textContent = Math.round(aw) + ":" + Math.round(ah)

    if (resH > 0 && resV > 0) {
      const diagPx = Math.sqrt(resH * resH + resV * resV)
      const ppi = diagPx / diagonal
      this.resultPpiTarget.textContent = ppi.toFixed(1) + " PPI"
      this.resultResolutionTarget.textContent = resH + " x " + resV
    } else {
      this.resultPpiTarget.textContent = "--"
      this.resultResolutionTarget.textContent = "--"
    }
  }

  copy() {
    const w = this.resultWidthTarget.textContent
    const h = this.resultHeightTarget.textContent
    const area = this.resultAreaTarget.textContent
    const ppi = this.resultPpiTarget.textContent
    const text = `Width: ${w}\nHeight: ${h}\nArea: ${area}\nPPI: ${ppi}`
    navigator.clipboard.writeText(text)
  }
}
