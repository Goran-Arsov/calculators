import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "direction", "justifyContent", "alignItems", "flexWrap", "gap",
    "preview", "cssOutput"
  ]

  connect() {
    this.generate()
  }

  generate() {
    var direction = this.directionTarget.value
    var justifyContent = this.justifyContentTarget.value
    var alignItems = this.alignItemsTarget.value
    var flexWrap = this.flexWrapTarget.value
    var gap = parseFloat(this.gapTarget.value) || 0

    var lines = []
    lines.push("display: flex;")
    lines.push("flex-direction: " + direction + ";")
    lines.push("justify-content: " + justifyContent + ";")
    lines.push("align-items: " + alignItems + ";")
    lines.push("flex-wrap: " + flexWrap + ";")
    if (gap > 0) lines.push("gap: " + gap + "px;")

    this.cssOutputTarget.textContent = lines.join("\n")

    var preview = this.previewTarget
    preview.style.display = "flex"
    preview.style.flexDirection = direction
    preview.style.justifyContent = justifyContent
    preview.style.alignItems = alignItems
    preview.style.flexWrap = flexWrap
    preview.style.gap = gap > 0 ? gap + "px" : "0"
  }

  copy() {
    navigator.clipboard.writeText(this.cssOutputTarget.textContent)
    this.element.querySelector("[data-copy-btn]").textContent = "Copied!"
    var self = this
    setTimeout(function() { self.element.querySelector("[data-copy-btn]").textContent = "Copy CSS" }, 2000)
  }
}
