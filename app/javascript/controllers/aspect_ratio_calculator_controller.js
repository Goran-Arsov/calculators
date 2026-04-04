import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "width", "height", "resultRatio", "resultDecimal",
    "newWidth", "ratioW", "ratioH", "resultNewHeight"
  ]

  calcRatio() {
    const w = parseInt(this.widthTarget.value)
    const h = parseInt(this.heightTarget.value)

    if (isNaN(w) || isNaN(h) || w <= 0 || h <= 0) {
      this.resultRatioTarget.textContent = "—"
      this.resultDecimalTarget.textContent = "—"
      return
    }

    const divisor = this.gcd(w, h)
    const ratioW = w / divisor
    const ratioH = h / divisor
    const decimal = w / h

    this.resultRatioTarget.textContent = `${ratioW}:${ratioH}`
    this.resultDecimalTarget.textContent = this.fmt(decimal)
  }

  calcResize() {
    const newWidth = parseFloat(this.newWidthTarget.value)
    const ratioW = parseFloat(this.ratioWTarget.value)
    const ratioH = parseFloat(this.ratioHTarget.value)

    if (isNaN(newWidth) || isNaN(ratioW) || isNaN(ratioH) || newWidth <= 0 || ratioW <= 0 || ratioH <= 0) {
      this.resultNewHeightTarget.textContent = "—"
      return
    }

    const newHeight = (newWidth * ratioH) / ratioW
    this.resultNewHeightTarget.textContent = this.fmt(newHeight)
  }

  gcd(a, b) {
    while (b) {
      [a, b] = [b, a % b]
    }
    return a
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
