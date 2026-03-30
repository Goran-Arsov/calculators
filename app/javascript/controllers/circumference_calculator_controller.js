import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["radius", "diameter", "circumference", "area", "radiusDisplay", "diameterDisplay"]

  calculateFromRadius() {
    const r = parseFloat(this.radiusTarget.value) || 0
    if (r <= 0) { this.clearResults(); return }

    this.diameterTarget.value = (r * 2).toFixed(4).replace(/\.?0+$/, "")
    this.update(r)
  }

  calculateFromDiameter() {
    const d = parseFloat(this.diameterTarget.value) || 0
    if (d <= 0) { this.clearResults(); return }

    this.radiusTarget.value = (d / 2).toFixed(4).replace(/\.?0+$/, "")
    this.update(d / 2)
  }

  update(r) {
    this.circumferenceTarget.textContent = (2 * Math.PI * r).toFixed(4).replace(/\.?0+$/, "")
    this.areaTarget.textContent = (Math.PI * r * r).toFixed(4).replace(/\.?0+$/, "")
    this.radiusDisplayTarget.textContent = r.toFixed(4).replace(/\.?0+$/, "")
    this.diameterDisplayTarget.textContent = (r * 2).toFixed(4).replace(/\.?0+$/, "")
  }

  clearResults() {
    this.circumferenceTarget.textContent = "0"
    this.areaTarget.textContent = "0"
    this.radiusDisplayTarget.textContent = "0"
    this.diameterDisplayTarget.textContent = "0"
  }

  copy() {
    const text = `Circumference: ${this.circumferenceTarget.textContent}\nArea: ${this.areaTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
