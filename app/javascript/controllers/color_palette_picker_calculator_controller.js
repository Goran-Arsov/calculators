import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "canvas", "sidebar", "swatch",
    "hexValue", "rgbValue", "hslValue",
    "crosshair"
  ]

  connect() {
    this.drawPalette()
    this.sidebarTarget.classList.add("hidden")
  }

  drawPalette() {
    const canvas = this.canvasTarget
    const ctx = canvas.getContext("2d")
    const width = canvas.width
    const height = canvas.height

    // Draw full hue spectrum horizontally, saturation vertically
    for (let x = 0; x < width; x++) {
      const hue = (x / width) * 360

      // Vertical gradient: full saturation at top, white at bottom
      const gradient = ctx.createLinearGradient(0, 0, 0, height)
      gradient.addColorStop(0, `hsl(${hue}, 100%, 50%)`)
      gradient.addColorStop(0.5, `hsl(${hue}, 100%, 75%)`)
      gradient.addColorStop(1, `hsl(${hue}, 20%, 95%)`)

      ctx.fillStyle = gradient
      ctx.fillRect(x, 0, 1, height)
    }

    // Overlay darkness gradient from bottom
    const darkOverlay = ctx.createLinearGradient(0, height * 0.6, 0, height)
    darkOverlay.addColorStop(0, "rgba(0,0,0,0)")
    darkOverlay.addColorStop(1, "rgba(0,0,0,0.7)")
    ctx.fillStyle = darkOverlay
    ctx.fillRect(0, 0, width, height)
  }

  pick(event) {
    const canvas = this.canvasTarget
    const rect = canvas.getBoundingClientRect()
    const scaleX = canvas.width / rect.width
    const scaleY = canvas.height / rect.height
    const x = Math.floor((event.clientX - rect.left) * scaleX)
    const y = Math.floor((event.clientY - rect.top) * scaleY)

    const ctx = canvas.getContext("2d")
    const pixel = ctx.getImageData(x, y, 1, 1).data
    const r = pixel[0], g = pixel[1], b = pixel[2]

    const hex = `#${this.toHex(r)}${this.toHex(g)}${this.toHex(b)}`
    const rgb = `rgb(${r}, ${g}, ${b})`
    const hsl = this.rgbToHslString(r, g, b)

    // Update swatch and values
    this.swatchTarget.style.backgroundColor = hex
    this.hexValueTarget.textContent = hex.toUpperCase()
    this.rgbValueTarget.textContent = rgb
    this.hslValueTarget.textContent = hsl

    // Show sidebar
    this.sidebarTarget.classList.remove("hidden")

    // Position crosshair
    if (this.hasCrosshairTarget) {
      const pxX = (event.clientX - rect.left)
      const pxY = (event.clientY - rect.top)
      this.crosshairTarget.style.left = `${pxX}px`
      this.crosshairTarget.style.top = `${pxY}px`
      this.crosshairTarget.classList.remove("hidden")
    }
  }

  copyHex() {
    this.copyText(this.hexValueTarget.textContent)
  }

  copyRgb() {
    this.copyText(this.rgbValueTarget.textContent)
  }

  copyHsl() {
    this.copyText(this.hslValueTarget.textContent)
  }

  copyText(text) {
    if (!text || text === "--") return
    navigator.clipboard.writeText(text).then(() => {
      // Brief flash feedback on the sidebar
      this.sidebarTarget.classList.add("ring-2", "ring-green-400")
      setTimeout(() => this.sidebarTarget.classList.remove("ring-2", "ring-green-400"), 600)
    })
  }

  toHex(n) {
    return n.toString(16).padStart(2, "0")
  }

  rgbToHslString(r, g, b) {
    r /= 255; g /= 255; b /= 255
    const max = Math.max(r, g, b), min = Math.min(r, g, b)
    let h, s, l = (max + min) / 2

    if (max === min) {
      h = s = 0
    } else {
      const d = max - min
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
      switch (max) {
        case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6; break
        case g: h = ((b - r) / d + 2) / 6; break
        case b: h = ((r - g) / d + 4) / 6; break
      }
    }

    return `hsl(${Math.round(h * 360)}, ${Math.round(s * 100)}%, ${Math.round(l * 100)}%)`
  }
}
