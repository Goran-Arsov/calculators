import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["length", "width", "height", "coats", "doors", "windows", "resultArea", "resultGallons"]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const coats = parseFloat(this.coatsTarget.value) || 2
    const doors = parseFloat(this.doorsTarget.value) || 1
    const windows = parseFloat(this.windowsTarget.value) || 2

    const wallArea = 2 * (length + width) * height
    const doorArea = doors * 21
    const windowArea = windows * 15
    const paintableArea = wallArea - doorArea - windowArea
    const gallons = (paintableArea * coats) / 350

    this.resultAreaTarget.textContent = this.fmt(Math.max(paintableArea, 0))
    this.resultGallonsTarget.textContent = this.fmt(Math.max(gallons, 0))
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
