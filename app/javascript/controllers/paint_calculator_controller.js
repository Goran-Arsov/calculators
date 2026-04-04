import { Controller } from "@hotwired/stimulus"

const SQ_FT_PER_DOOR = 20
const SQ_FT_PER_WINDOW = 15
const SQ_FT_PER_GALLON = 350

export default class extends Controller {
  static targets = ["length", "width", "height", "coats", "doors", "windows", "resultWallArea", "resultPaintableArea", "resultGallons"]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const coats = parseInt(this.coatsTarget.value) || 2
    const doors = parseInt(this.doorsTarget.value) || 0
    const windows = parseInt(this.windowsTarget.value) || 0

    const wallArea = 2 * (length + width) * height
    const doorArea = doors * SQ_FT_PER_DOOR
    const windowArea = windows * SQ_FT_PER_WINDOW
    const paintableArea = Math.max(wallArea - doorArea - windowArea, 0)
    const gallons = paintableArea > 0 ? Math.ceil((paintableArea * coats) / SQ_FT_PER_GALLON) : 0

    this.resultWallAreaTarget.textContent = `${this.fmt(wallArea)} sq ft`
    this.resultPaintableAreaTarget.textContent = `${this.fmt(paintableArea)} sq ft`
    this.resultGallonsTarget.textContent = gallons
  }

  copy() {
    const wallArea = this.resultWallAreaTarget.textContent
    const paintableArea = this.resultPaintableAreaTarget.textContent
    const gallons = this.resultGallonsTarget.textContent
    const text = `Paint Estimate:\nWall Area: ${wallArea}\nPaintable Area: ${paintableArea}\nGallons Needed: ${gallons}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
