import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "markupIn", "resultMarginFromMarkup",
    "marginIn", "resultMarkupFromMargin"
  ]

  calcMargin() {
    const markup = parseFloat(this.markupInTarget.value)
    if (!isNaN(markup) && markup > -100) {
      const margin = (markup / (100 + markup)) * 100
      this.resultMarginFromMarkupTarget.textContent = this.fmt(margin) + "%"
    } else {
      this.resultMarginFromMarkupTarget.textContent = "—"
    }
  }

  calcMarkup() {
    const margin = parseFloat(this.marginInTarget.value)
    if (!isNaN(margin) && margin < 100) {
      const markup = (margin / (100 - margin)) * 100
      this.resultMarkupFromMarginTarget.textContent = this.fmt(markup) + "%"
    } else {
      this.resultMarkupFromMarginTarget.textContent = "—"
    }
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const result = card.querySelector("[data-result]")
    navigator.clipboard.writeText(`${card.dataset.card}: ${result.textContent}`)
  }
}
