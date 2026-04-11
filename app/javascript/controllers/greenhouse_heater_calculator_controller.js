import { Controller } from "@hotwired/stimulus"

const U_VALUES = {
  single_poly: 1.15,
  double_poly: 0.70,
  single_glass: 1.13,
  double_glass: 0.65,
  polycarbonate_twin: 0.65,
  polycarbonate_triple: 0.58,
  fiberglass: 1.00
}

export default class extends Controller {
  static targets = [
    "length", "width", "height", "desired", "outside", "glazing",
    "resultSurface", "resultDelta", "resultU", "resultBtu", "resultWatts"
  ]

  connect() { this.calculate() }

  calculate() {
    const length = parseFloat(this.lengthTarget.value)
    const width = parseFloat(this.widthTarget.value)
    const height = parseFloat(this.heightTarget.value)
    const desired = parseFloat(this.desiredTarget.value)
    const outside = parseFloat(this.outsideTarget.value)
    const u = U_VALUES[this.glazingTarget.value]

    if (!Number.isFinite(length) || length <= 0 ||
        !Number.isFinite(width) || width <= 0 ||
        !Number.isFinite(height) || height <= 0 ||
        !Number.isFinite(desired) || !Number.isFinite(outside) ||
        desired <= outside || !u) {
      this.clear()
      return
    }

    const surface = 2 * (length * width + length * height + width * height)
    const delta = desired - outside
    const btu = surface * delta * u
    const watts = btu * 0.293071

    this.resultSurfaceTarget.textContent = `${surface.toFixed(0)} sq ft`
    this.resultDeltaTarget.textContent = `${delta.toFixed(0)} °F`
    this.resultUTarget.textContent = `${u.toFixed(2)}`
    this.resultBtuTarget.textContent = `${Math.round(btu).toLocaleString()} BTU/hr`
    this.resultWattsTarget.textContent = `${Math.round(watts).toLocaleString()} W`
  }

  clear() {
    this.resultSurfaceTarget.textContent = "—"
    this.resultDeltaTarget.textContent = "—"
    this.resultUTarget.textContent = "—"
    this.resultBtuTarget.textContent = "—"
    this.resultWattsTarget.textContent = "—"
  }

  copy() {
    const text = `Greenhouse heater sizing:\nSurface area: ${this.resultSurfaceTarget.textContent}\nΔT: ${this.resultDeltaTarget.textContent}\nU-value: ${this.resultUTarget.textContent}\nBTU/hr: ${this.resultBtuTarget.textContent}\nWatts: ${this.resultWattsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
