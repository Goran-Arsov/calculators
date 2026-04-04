import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "gainForRoi", "costForRoi", "resultRoi",
    "roiForGain", "costForGain", "resultGain",
    "roiForCost", "gainForCost", "resultCost"
  ]

  calcRoi() {
    const gain = parseFloat(this.gainForRoiTarget.value)
    const cost = parseFloat(this.costForRoiTarget.value)
    if (!isNaN(gain) && cost > 0) {
      this.resultRoiTarget.textContent = this.fmt((gain - cost) / cost * 100) + "%"
    } else {
      this.resultRoiTarget.textContent = "—"
    }
  }

  calcGain() {
    const roi = parseFloat(this.roiForGainTarget.value)
    const cost = parseFloat(this.costForGainTarget.value)
    if (!isNaN(roi) && !isNaN(cost) && cost > 0) {
      this.resultGainTarget.textContent = "$" + this.fmt(cost * (1 + roi / 100))
    } else {
      this.resultGainTarget.textContent = "—"
    }
  }

  calcCost() {
    const roi = parseFloat(this.roiForCostTarget.value)
    const gain = parseFloat(this.gainForCostTarget.value)
    if (!isNaN(roi) && roi !== -100 && !isNaN(gain)) {
      this.resultCostTarget.textContent = "$" + this.fmt(gain / (1 + roi / 100))
    } else {
      this.resultCostTarget.textContent = "—"
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
