import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hueBar", "satBox", "swatch", "hexValue", "rgbValue", "hslValue", "hueMarker", "satMarker"]

  connect() {
    this.hue = 210
    this.saturation = 80
    this.brightness = 55
    this.updateSatBoxBg()
    this.showColor()
  }

  clickHue(event) {
    var rect = this.hueBarTarget.getBoundingClientRect()
    var x = event.clientX - rect.left
    if (x < 0) x = 0
    if (x > rect.width) x = rect.width
    this.hue = Math.round((x / rect.width) * 360)
    this.hueMarkerTarget.style.left = ((x / rect.width) * 100) + "%"
    this.updateSatBoxBg()
    this.showColor()
  }

  clickSat(event) {
    var rect = this.satBoxTarget.getBoundingClientRect()
    var x = event.clientX - rect.left
    var y = event.clientY - rect.top
    if (x < 0) x = 0
    if (x > rect.width) x = rect.width
    if (y < 0) y = 0
    if (y > rect.height) y = rect.height
    this.saturation = Math.round((x / rect.width) * 100)
    this.brightness = Math.round(100 - (y / rect.height) * 100)
    this.satMarkerTarget.style.left = ((x / rect.width) * 100) + "%"
    this.satMarkerTarget.style.top = ((y / rect.height) * 100) + "%"
    this.showColor()
  }

  updateSatBoxBg() {
    this.satBoxTarget.style.background = "linear-gradient(to top, #000, transparent), linear-gradient(to right, #fff, hsl(" + this.hue + ", 100%, 50%))"
  }

  showColor() {
    var rgb = this.convertHslToRgb(this.hue, this.saturation, this.brightness)
    var hex = "#" + this.pad(rgb[0]) + this.pad(rgb[1]) + this.pad(rgb[2])
    this.swatchTarget.style.backgroundColor = hex
    this.hexValueTarget.textContent = hex.toUpperCase()
    this.rgbValueTarget.textContent = "rgb(" + rgb[0] + ", " + rgb[1] + ", " + rgb[2] + ")"
    this.hslValueTarget.textContent = "hsl(" + this.hue + ", " + this.saturation + "%, " + this.brightness + "%)"
  }

  pad(n) {
    var s = n.toString(16)
    return s.length < 2 ? "0" + s : s
  }

  convertHslToRgb(h, s, l) {
    s = s / 100
    l = l / 100
    var c = (1 - Math.abs(2 * l - 1)) * s
    var x = c * (1 - Math.abs((h / 60) % 2 - 1))
    var m = l - c / 2
    var r = 0, g = 0, b = 0
    if (h < 60)       { r = c; g = x; b = 0 }
    else if (h < 120) { r = x; g = c; b = 0 }
    else if (h < 180) { r = 0; g = c; b = x }
    else if (h < 240) { r = 0; g = x; b = c }
    else if (h < 300) { r = x; g = 0; b = c }
    else              { r = c; g = 0; b = x }
    return [Math.round((r + m) * 255), Math.round((g + m) * 255), Math.round((b + m) * 255)]
  }

  copyHex() { navigator.clipboard.writeText(this.hexValueTarget.textContent) }
  copyRgb() { navigator.clipboard.writeText(this.rgbValueTarget.textContent) }
  copyHsl() { navigator.clipboard.writeText(this.hslValueTarget.textContent) }
}
