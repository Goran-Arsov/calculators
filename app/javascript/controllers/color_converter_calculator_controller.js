import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "colorPicker", "hexInput", "rgbR", "rgbG", "rgbB",
    "hslH", "hslS", "hslL",
    "preview", "resultHex", "resultRgb", "resultHsl",
    "resultColorName", "resultLuminance",
    "resultContrastWhite", "resultContrastBlack",
    "resultWcagWhiteAaNormal", "resultWcagWhiteAaLarge",
    "resultWcagWhiteAaaNormal", "resultWcagWhiteAaaLarge",
    "resultWcagBlackAaNormal", "resultWcagBlackAaLarge",
    "resultWcagBlackAaaNormal", "resultWcagBlackAaaLarge",
    "resultBestText"
  ]

  static namedColors = {
    "000000": "Black", "ffffff": "White", "ff0000": "Red",
    "00ff00": "Lime", "0000ff": "Blue", "ffff00": "Yellow",
    "00ffff": "Cyan", "ff00ff": "Magenta", "c0c0c0": "Silver",
    "808080": "Gray", "800000": "Maroon", "808000": "Olive",
    "008000": "Green", "800080": "Purple", "008080": "Teal",
    "000080": "Navy", "ffa500": "Orange", "ffc0cb": "Pink",
    "a52a2a": "Brown", "f5f5dc": "Beige", "ff7f50": "Coral",
    "ffd700": "Gold", "4b0082": "Indigo", "fffff0": "Ivory",
    "e6e6fa": "Lavender", "fa8072": "Salmon", "d2b48c": "Tan",
    "ee82ee": "Violet", "f5f5f5": "WhiteSmoke", "ff6347": "Tomato",
    "40e0d0": "Turquoise", "da70d6": "Orchid", "dda0dd": "Plum",
    "b0e0e6": "PowderBlue", "f0e68c": "Khaki", "e0ffff": "LightCyan"
  }

  fromPicker() {
    const hex = this.colorPickerTarget.value.replace("#", "")
    this.hexInputTarget.value = "#" + hex.toUpperCase()
    const { r, g, b } = this.hexToRgb(hex)
    this.rgbRTarget.value = r
    this.rgbGTarget.value = g
    this.rgbBTarget.value = b
    const { h, s, l } = this.rgbToHsl(r, g, b)
    this.hslHTarget.value = h
    this.hslSTarget.value = s
    this.hslLTarget.value = l
    this.updateResults(r, g, b, hex, h, s, l)
  }

  fromHex() {
    let hex = this.hexInputTarget.value.replace("#", "").trim()
    if (hex.length === 3) {
      hex = hex.split("").map(c => c + c).join("")
    }
    if (!/^[0-9a-fA-F]{6}$/.test(hex)) return

    this.colorPickerTarget.value = "#" + hex
    const { r, g, b } = this.hexToRgb(hex)
    this.rgbRTarget.value = r
    this.rgbGTarget.value = g
    this.rgbBTarget.value = b
    const { h, s, l } = this.rgbToHsl(r, g, b)
    this.hslHTarget.value = h
    this.hslSTarget.value = s
    this.hslLTarget.value = l
    this.updateResults(r, g, b, hex, h, s, l)
  }

  fromRgb() {
    const r = this.clamp(parseInt(this.rgbRTarget.value) || 0, 0, 255)
    const g = this.clamp(parseInt(this.rgbGTarget.value) || 0, 0, 255)
    const b = this.clamp(parseInt(this.rgbBTarget.value) || 0, 0, 255)

    const hex = this.rgbToHex(r, g, b)
    this.hexInputTarget.value = "#" + hex.toUpperCase()
    this.colorPickerTarget.value = "#" + hex
    const { h, s, l } = this.rgbToHsl(r, g, b)
    this.hslHTarget.value = h
    this.hslSTarget.value = s
    this.hslLTarget.value = l
    this.updateResults(r, g, b, hex, h, s, l)
  }

  fromHsl() {
    const h = this.clamp(parseFloat(this.hslHTarget.value) || 0, 0, 360)
    const s = this.clamp(parseFloat(this.hslSTarget.value) || 0, 0, 100)
    const l = this.clamp(parseFloat(this.hslLTarget.value) || 0, 0, 100)

    const { r, g, b } = this.hslToRgb(h, s, l)
    const hex = this.rgbToHex(r, g, b)
    this.hexInputTarget.value = "#" + hex.toUpperCase()
    this.colorPickerTarget.value = "#" + hex
    this.rgbRTarget.value = r
    this.rgbGTarget.value = g
    this.rgbBTarget.value = b
    this.updateResults(r, g, b, hex, h, s, l)
  }

  updateResults(r, g, b, hex, h, s, l) {
    const hexLower = hex.toLowerCase()
    this.previewTarget.style.backgroundColor = `#${hex}`
    this.resultHexTarget.textContent = `#${hex.toUpperCase()}`
    this.resultRgbTarget.textContent = `rgb(${r}, ${g}, ${b})`
    this.resultHslTarget.textContent = `hsl(${h}, ${s}%, ${l}%)`

    const namedColors = this.constructor.namedColors
    this.resultColorNameTarget.textContent = namedColors[hexLower] || "Custom"

    const luminance = this.relativeLuminance(r, g, b)
    this.resultLuminanceTarget.textContent = luminance.toFixed(4)

    const contrastWhite = this.contrastRatio(luminance, 1.0)
    const contrastBlack = this.contrastRatio(luminance, 0.0)
    this.resultContrastWhiteTarget.textContent = contrastWhite.toFixed(2) + ":1"
    this.resultContrastBlackTarget.textContent = contrastBlack.toFixed(2) + ":1"

    this.setWcagBadge(this.resultWcagWhiteAaNormalTarget, contrastWhite >= 4.5)
    this.setWcagBadge(this.resultWcagWhiteAaLargeTarget, contrastWhite >= 3.0)
    this.setWcagBadge(this.resultWcagWhiteAaaNormalTarget, contrastWhite >= 7.0)
    this.setWcagBadge(this.resultWcagWhiteAaaLargeTarget, contrastWhite >= 4.5)

    this.setWcagBadge(this.resultWcagBlackAaNormalTarget, contrastBlack >= 4.5)
    this.setWcagBadge(this.resultWcagBlackAaLargeTarget, contrastBlack >= 3.0)
    this.setWcagBadge(this.resultWcagBlackAaaNormalTarget, contrastBlack >= 7.0)
    this.setWcagBadge(this.resultWcagBlackAaaLargeTarget, contrastBlack >= 4.5)

    const bestText = contrastWhite >= contrastBlack ? "#FFFFFF" : "#000000"
    this.resultBestTextTarget.textContent = bestText
    this.resultBestTextTarget.style.backgroundColor = `#${hex}`
    this.resultBestTextTarget.style.color = bestText
    this.resultBestTextTarget.style.padding = "2px 8px"
    this.resultBestTextTarget.style.borderRadius = "4px"
  }

  setWcagBadge(target, passes) {
    target.textContent = passes ? "Pass" : "Fail"
    target.className = passes
      ? "inline-block px-2 py-0.5 text-xs font-semibold rounded-full bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400"
      : "inline-block px-2 py-0.5 text-xs font-semibold rounded-full bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"
  }

  hexToRgb(hex) {
    return {
      r: parseInt(hex.substring(0, 2), 16),
      g: parseInt(hex.substring(2, 4), 16),
      b: parseInt(hex.substring(4, 6), 16)
    }
  }

  rgbToHex(r, g, b) {
    return [r, g, b].map(v => v.toString(16).padStart(2, "0")).join("")
  }

  rgbToHsl(r, g, b) {
    const rn = r / 255, gn = g / 255, bn = b / 255
    const max = Math.max(rn, gn, bn), min = Math.min(rn, gn, bn)
    const delta = max - min
    const l = (max + min) / 2

    let h = 0, s = 0
    if (delta !== 0) {
      s = l < 0.5 ? delta / (max + min) : delta / (2 - max - min)
      if (max === rn) h = ((gn - bn) / delta) % 6
      else if (max === gn) h = (bn - rn) / delta + 2
      else h = (rn - gn) / delta + 4
      h *= 60
      if (h < 0) h += 360
    }

    return { h: Math.round(h), s: Math.round(s * 100), l: Math.round(l * 100) }
  }

  hslToRgb(h, s, l) {
    const sn = s / 100, ln = l / 100
    const c = (1 - Math.abs(2 * ln - 1)) * sn
    const x = c * (1 - Math.abs((h / 60) % 2 - 1))
    const m = ln - c / 2

    let r1, g1, b1
    if (h < 60) { r1 = c; g1 = x; b1 = 0 }
    else if (h < 120) { r1 = x; g1 = c; b1 = 0 }
    else if (h < 180) { r1 = 0; g1 = c; b1 = x }
    else if (h < 240) { r1 = 0; g1 = x; b1 = c }
    else if (h < 300) { r1 = x; g1 = 0; b1 = c }
    else { r1 = c; g1 = 0; b1 = x }

    return {
      r: Math.round((r1 + m) * 255),
      g: Math.round((g1 + m) * 255),
      b: Math.round((b1 + m) * 255)
    }
  }

  relativeLuminance(r, g, b) {
    const linearize = (v) => {
      const srgb = v / 255
      return srgb <= 0.03928 ? srgb / 12.92 : Math.pow((srgb + 0.055) / 1.055, 2.4)
    }
    return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
  }

  contrastRatio(lum1, lum2) {
    const lighter = Math.max(lum1, lum2)
    const darker = Math.min(lum1, lum2)
    return (lighter + 0.05) / (darker + 0.05)
  }

  clamp(value, min, max) {
    return Math.min(Math.max(value, min), max)
  }

  copyResult(event) {
    const targetName = event.params.target
    const el = this[`${targetName}Target`]
    if (el) {
      navigator.clipboard.writeText(el.textContent)
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 1500)
    }
  }

  copy() {
    const lines = [
      `HEX: ${this.resultHexTarget.textContent}`,
      `RGB: ${this.resultRgbTarget.textContent}`,
      `HSL: ${this.resultHslTarget.textContent}`,
      `Color Name: ${this.resultColorNameTarget.textContent}`,
      `Luminance: ${this.resultLuminanceTarget.textContent}`,
      `Contrast vs White: ${this.resultContrastWhiteTarget.textContent}`,
      `Contrast vs Black: ${this.resultContrastBlackTarget.textContent}`,
      `Best Text Color: ${this.resultBestTextTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
