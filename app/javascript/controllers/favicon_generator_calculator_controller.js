import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "text", "bgColor", "textColor", "fontSize", "fontSizeValue",
    "shape", "preview16", "preview32", "preview48", "preview180",
    "htmlOutput"
  ]

  connect() {
    this.currentShape = "square"
    this.generate()
  }

  updateFontSize() {
    this.fontSizeValueTarget.textContent = this.fontSizeTarget.value + "%"
    this.generate()
  }

  setShape(event) {
    this.currentShape = event.currentTarget.dataset.shape
    var buttons = this.element.querySelectorAll("[data-shape]")
    for (var i = 0; i < buttons.length; i++) {
      if (buttons[i].dataset.shape === this.currentShape) {
        buttons[i].classList.add("bg-blue-600", "text-white")
        buttons[i].classList.remove("bg-gray-100", "dark:bg-gray-700", "text-gray-700", "dark:text-gray-300")
      } else {
        buttons[i].classList.remove("bg-blue-600", "text-white")
        buttons[i].classList.add("bg-gray-100", "dark:bg-gray-700", "text-gray-700", "dark:text-gray-300")
      }
    }
    this.generate()
  }

  generate() {
    var text = this.textTarget.value || "A"
    var bgColor = this.bgColorTarget.value
    var textColor = this.textColorTarget.value
    var fontPercent = parseInt(this.fontSizeTarget.value) || 60

    var sizes = [
      { size: 16, target: this.preview16Target },
      { size: 32, target: this.preview32Target },
      { size: 48, target: this.preview48Target },
      { size: 180, target: this.preview180Target }
    ]

    for (var i = 0; i < sizes.length; i++) {
      this.drawCanvas(sizes[i].target, sizes[i].size, text, bgColor, textColor, fontPercent)
    }

    this.updateHtmlTags()
  }

  drawCanvas(canvas, size, text, bgColor, textColor, fontPercent) {
    canvas.width = size
    canvas.height = size
    var ctx = canvas.getContext("2d")

    // Background
    ctx.fillStyle = bgColor
    if (this.currentShape === "circle") {
      ctx.beginPath()
      ctx.arc(size / 2, size / 2, size / 2, 0, Math.PI * 2)
      ctx.fill()
    } else {
      ctx.fillRect(0, 0, size, size)
    }

    // Text
    var fontSize = Math.round(size * fontPercent / 100)
    ctx.fillStyle = textColor
    ctx.font = "bold " + fontSize + "px -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    ctx.textAlign = "center"
    ctx.textBaseline = "middle"
    ctx.fillText(text, size / 2, size / 2 + (size * 0.03))
  }

  updateHtmlTags() {
    var lines = []
    lines.push('<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">')
    lines.push('<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">')
    lines.push('<link rel="icon" type="image/png" sizes="48x48" href="/favicon-48x48.png">')
    lines.push('<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">')
    this.htmlOutputTarget.textContent = lines.join("\n")
  }

  downloadAll() {
    var sizes = [
      { size: 16, name: "favicon-16x16.png", target: this.preview16Target },
      { size: 32, name: "favicon-32x32.png", target: this.preview32Target },
      { size: 48, name: "favicon-48x48.png", target: this.preview48Target },
      { size: 180, name: "apple-touch-icon.png", target: this.preview180Target }
    ]

    for (var i = 0; i < sizes.length; i++) {
      (function(item) {
        item.target.toBlob(function(blob) {
          var url = URL.createObjectURL(blob)
          var a = document.createElement("a")
          a.href = url
          a.download = item.name
          document.body.appendChild(a)
          a.click()
          document.body.removeChild(a)
          URL.revokeObjectURL(url)
        })
      })(sizes[i])
    }
  }

  copyHtml() {
    navigator.clipboard.writeText(this.htmlOutputTarget.textContent)
    this.element.querySelector("[data-copy-html]").textContent = "Copied!"
    var self = this
    setTimeout(function() { self.element.querySelector("[data-copy-html]").textContent = "Copy HTML" }, 2000)
  }
}
