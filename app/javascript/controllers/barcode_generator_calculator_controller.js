import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "textInput", "formatSelect", "barcodeOutput", "downloadArea", "statusMessage"
  ]

  // Code 128B encoding table: values 0-106
  // Each value maps to a pattern of 6 alternating bar/space widths (11 modules total)
  CODE128B_PATTERNS = [
    [2,1,2,2,2,2],[2,2,2,1,2,2],[2,2,2,2,2,1],[1,2,1,2,2,3],[1,2,1,3,2,2],
    [1,3,1,2,2,2],[1,2,2,2,1,3],[1,2,2,3,1,2],[1,3,2,2,1,2],[2,2,1,2,1,3],
    [2,2,1,3,1,2],[2,3,1,2,1,2],[1,1,2,2,3,2],[1,2,2,1,3,2],[1,2,2,2,3,1],
    [1,1,3,2,2,2],[1,2,3,1,2,2],[1,2,3,2,2,1],[2,2,3,2,1,1],[2,2,1,1,3,2],
    [2,2,1,2,3,1],[2,1,3,2,1,2],[2,2,3,1,1,2],[3,1,2,1,3,1],[3,1,1,2,2,2],
    [3,2,1,1,2,2],[3,2,1,2,2,1],[3,1,2,2,1,2],[3,2,2,1,1,2],[3,2,2,2,1,1],
    [2,1,2,1,2,3],[2,1,2,3,2,1],[2,3,2,1,2,1],[1,1,1,3,2,3],[1,3,1,1,2,3],
    [1,3,1,3,2,1],[1,1,2,3,1,3],[1,3,2,1,1,3],[1,3,2,3,1,1],[2,1,1,3,1,3],
    [2,3,1,1,1,3],[2,3,1,3,1,1],[1,1,2,1,3,3],[1,1,2,3,3,1],[1,3,2,1,3,1],
    [1,1,3,1,2,3],[1,1,3,3,2,1],[1,3,3,1,2,1],[3,1,3,1,2,1],[2,1,1,3,3,1],
    [2,3,1,1,3,1],[2,1,3,1,1,3],[2,1,3,3,1,1],[2,1,3,1,3,1],[3,1,1,1,2,3],
    [3,1,1,3,2,1],[3,3,1,1,2,1],[3,1,2,1,1,3],[3,1,2,3,1,1],[3,3,2,1,1,1],
    [3,1,4,1,1,1],[2,2,1,4,1,1],[4,3,1,1,1,1],[1,1,1,2,2,4],[1,1,1,4,2,2],
    [1,2,1,1,2,4],[1,2,1,4,2,1],[1,4,1,1,2,2],[1,4,1,2,2,1],[1,1,2,2,1,4],
    [1,1,2,4,1,2],[1,2,2,1,1,4],[1,2,2,4,1,1],[1,4,2,1,1,2],[1,4,2,2,1,1],
    [2,4,1,2,1,1],[2,2,1,1,1,4],[4,1,3,1,1,1],[2,4,1,1,1,2],[1,3,4,1,1,1],
    [1,1,1,2,4,2],[1,2,1,1,4,2],[1,2,1,2,4,1],[1,1,4,2,1,2],[1,2,4,1,1,2],
    [1,2,4,2,1,1],[4,1,1,2,1,2],[4,2,1,1,1,2],[4,2,1,2,1,1],[2,1,2,1,4,1],
    [2,1,4,1,2,1],[4,1,2,1,2,1],[1,1,1,1,4,3],[1,1,1,3,4,1],[1,3,1,1,4,1],
    [1,1,4,1,1,3],[1,1,4,3,1,1],[4,1,1,1,1,3],[4,1,1,3,1,1],[1,1,3,1,4,1],
    [1,1,4,1,3,1],[3,1,1,1,4,1],[4,1,1,1,3,1],[2,1,1,4,1,2],[2,1,1,2,1,4],
    [2,1,1,2,3,2],[2,3,3,1,1,1,2]
  ]

  STOP_PATTERN = [2,3,3,1,1,1,2]

  CODE39_PATTERNS = {
    "0": "nnnwwnwnn", "1": "wnnwnnnnw", "2": "nnwwnnnnw", "3": "wnwwnnnn",
    "4": "nnnwwnnnw", "5": "wnnwwnnn", "6": "nnwwwnnn", "7": "nnnwnnwnw",
    "8": "wnnwnnwn", "9": "nnwwnnwn",
    "A": "wnnnnwnnw", "B": "nnwnnwnnw", "C": "wnwnnwnn", "D": "nnnnwwnnw",
    "E": "wnnnwwnn", "F": "nnwnwwnn", "G": "nnnnnwwnw", "H": "wnnnnwwn",
    "I": "nnwnnwwn", "J": "nnnnwwwn",
    "K": "wnnnnnnww", "L": "nnwnnnnww", "M": "wnwnnnnw", "N": "nnnnwnnww",
    "O": "wnnnwnnw", "P": "nnwnwnnw", "Q": "nnnnnnwww", "R": "wnnnnnww",
    "S": "nnwnnnww", "T": "nnnnwnww",
    "U": "wwnnnnnn w", "V": "nwwnnnnnw", "W": "wwwnnnnnn", "X": "nwnnwnnnw",
    "Y": "wwnnwnnnn", "Z": "nwwnwnnnn",
    "-": "nwnnnnwnw", ".": "wwnnnnwn", " ": "nwwnnnwn",
    "$": "nwnwnwnn", "/": "nwnwnnnw", "+": "nwnnnwnw", "%": "nnnwnwnw",
    "*": "nwnnwnwn"
  }

  generate() {
    const text = this.textInputTarget.value
    const format = this.formatSelectTarget.value

    if (!text || !text.trim()) {
      this.showStatus("Enter text to generate a barcode", "error")
      return
    }

    let svg
    switch (format) {
      case "code128":
        svg = this.generateCode128(text)
        break
      case "ean13":
        svg = this.generateEan13(text)
        break
      case "code39":
        svg = this.generateCode39(text.toUpperCase())
        break
      default:
        this.showStatus("Unsupported format", "error")
        return
    }

    if (svg) {
      this.barcodeOutputTarget.innerHTML = svg
      this.downloadAreaTarget.classList.remove("hidden")
      this.showStatus(`${format.toUpperCase()} barcode generated`, "success")
    }
  }

  generateCode128(text) {
    // Validate ASCII 32-127
    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i)
      if (code < 32 || code > 127) {
        this.showStatus("Code 128 only supports ASCII characters 32-127", "error")
        return null
      }
    }

    const START_B = 104
    const values = [START_B]

    for (let i = 0; i < text.length; i++) {
      values.push(text.charCodeAt(i) - 32)
    }

    // Calculate checksum
    let checksum = values[0]
    for (let i = 1; i < values.length; i++) {
      checksum += values[i] * i
    }
    checksum = checksum % 103
    values.push(checksum)

    // Build bar pattern
    const bars = []
    for (const val of values) {
      const pattern = this.CODE128B_PATTERNS[val]
      if (pattern) bars.push(...pattern)
    }
    // Stop pattern
    bars.push(...this.STOP_PATTERN)

    return this.renderSvg(bars, text)
  }

  generateEan13(text) {
    let digits = text.replace(/\D/g, "")
    if (digits.length !== 12 && digits.length !== 13) {
      this.showStatus("EAN-13 requires exactly 12 or 13 digits", "error")
      return null
    }

    // Calculate check digit if 12 digits
    if (digits.length === 12) {
      let sum = 0
      for (let i = 0; i < 12; i++) {
        sum += parseInt(digits[i]) * (i % 2 === 0 ? 1 : 3)
      }
      digits += ((10 - (sum % 10)) % 10).toString()
    }

    // EAN-13 encoding
    const PARITY = [
      "LLLLLL", "LLGLGG", "LLGGLG", "LLGGGL", "LGLLGG",
      "LGGLLG", "LGGGLL", "LGLGLG", "LGLGGL", "LGGLGL"
    ]

    const L_CODES = [
      [0,0,0,1,1,0,1], [0,0,1,1,0,0,1], [0,0,1,0,0,1,1], [0,1,1,1,1,0,1],
      [0,1,0,0,0,1,1], [0,1,1,0,0,0,1], [0,1,0,1,1,1,1], [0,1,1,1,0,1,1],
      [0,1,1,0,1,1,1], [0,0,0,1,0,1,1]
    ]

    const G_CODES = [
      [0,1,0,0,1,1,1], [0,1,1,0,0,1,1], [0,0,1,1,0,1,1], [0,1,0,0,0,0,1],
      [0,0,1,1,1,0,1], [0,1,1,1,0,0,1], [0,0,0,0,1,0,1], [0,0,1,0,0,0,1],
      [0,0,0,1,0,0,1], [0,0,1,0,1,1,1]
    ]

    const R_CODES = [
      [1,1,1,0,0,1,0], [1,1,0,0,1,1,0], [1,1,0,1,1,0,0], [1,0,0,0,0,1,0],
      [1,0,1,1,1,0,0], [1,0,0,1,1,1,0], [1,0,1,0,0,0,0], [1,0,0,0,1,0,0],
      [1,0,0,1,0,0,0], [1,1,1,0,1,0,0]
    ]

    const modules = []

    // Start guard
    modules.push(1, 0, 1)

    const parityPattern = PARITY[parseInt(digits[0])]

    // Left side (digits 1-6)
    for (let i = 0; i < 6; i++) {
      const d = parseInt(digits[i + 1])
      const encoding = parityPattern[i] === "L" ? L_CODES[d] : G_CODES[d]
      modules.push(...encoding)
    }

    // Center guard
    modules.push(0, 1, 0, 1, 0)

    // Right side (digits 7-12)
    for (let i = 0; i < 6; i++) {
      const d = parseInt(digits[i + 7])
      modules.push(...R_CODES[d])
    }

    // End guard
    modules.push(1, 0, 1)

    // Convert modules to bars format (alternating widths)
    const bars = []
    let current = modules[0]
    let count = 1
    for (let i = 1; i < modules.length; i++) {
      if (modules[i] === current) {
        count++
      } else {
        bars.push(count)
        current = modules[i]
        count = 1
      }
    }
    bars.push(count)

    // If first module is 0 (space), prepend a 0-width bar
    if (modules[0] === 0) {
      bars.unshift(0)
    }

    return this.renderSvg(bars, digits)
  }

  generateCode39(text) {
    // Validate
    const valid = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%"
    for (const ch of text) {
      if (!valid.includes(ch)) {
        this.showStatus(`Invalid Code 39 character: ${ch}`, "error")
        return null
      }
    }

    const fullText = `*${text}*`
    const modules = []

    for (let ci = 0; ci < fullText.length; ci++) {
      if (ci > 0) modules.push(0) // inter-character gap (narrow space)

      const ch = fullText[ci]
      const pattern = this.getCode39Pattern(ch)
      if (!pattern) continue

      for (let i = 0; i < pattern.length; i++) {
        const isBar = i % 2 === 0
        const isWide = pattern[i] === "w"
        const width = isWide ? 3 : 1
        for (let w = 0; w < width; w++) {
          modules.push(isBar ? 1 : 0)
        }
      }
    }

    // Convert modules to alternating widths
    const bars = []
    if (modules.length === 0) return null

    let current = modules[0]
    let count = 1
    for (let i = 1; i < modules.length; i++) {
      if (modules[i] === current) {
        count++
      } else {
        bars.push(count)
        current = modules[i]
        count = 1
      }
    }
    bars.push(count)

    if (modules[0] === 0) bars.unshift(0)

    return this.renderSvg(bars, text)
  }

  getCode39Pattern(ch) {
    const patterns = {
      "0": "nnnwwnwnn", "1": "wnnwnnnnw", "2": "nnwwnnnnw", "3": "wnwwnnnnn",
      "4": "nnnwwnnnw", "5": "wnnwwnnnn", "6": "nnwwwnnnn", "7": "nnnwnnwnw",
      "8": "wnnwnnwnn", "9": "nnwwnnwnn",
      "A": "wnnnnwnnw", "B": "nnwnnwnnw", "C": "wnwnnwnnn", "D": "nnnnwwnnw",
      "E": "wnnnwwnnn", "F": "nnwnwwnnn", "G": "nnnnnwwnw", "H": "wnnnnwwnn",
      "I": "nnwnnwwnn", "J": "nnnnwwwnn",
      "K": "wnnnnnnww", "L": "nnwnnnnww", "M": "wnwnnnnwn", "N": "nnnnwnnww",
      "O": "wnnnwnnwn", "P": "nnwnwnnwn", "Q": "nnnnnnwww", "R": "wnnnnnwwn",
      "S": "nnwnnnwwn", "T": "nnnnwnwwn",
      "U": "wwnnnnnnw", "V": "nwwnnnnnw", "W": "wwwnnnnnn", "X": "nwnnwnnnw",
      "Y": "wwnnwnnn", "Z": "nwwnwnnn",
      "-": "nwnnnnwnw", ".": "wwnnnnwnn", " ": "nwwnnnnwn",
      "$": "nwnwnwnnn", "/": "nwnwnnnwn", "+": "nwnnnwnwn", "%": "nnnwnwnwn",
      "*": "nwnnwnwnn"
    }
    return patterns[ch]
  }

  renderSvg(bars, label) {
    const moduleWidth = 2
    const height = 80
    const labelHeight = 20
    const quietZone = 20
    let totalWidth = 0
    for (const w of bars) totalWidth += w * moduleWidth

    const svgWidth = totalWidth + quietZone * 2
    const svgHeight = height + labelHeight

    let x = quietZone
    let svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${svgWidth}" height="${svgHeight}" viewBox="0 0 ${svgWidth} ${svgHeight}" class="mx-auto">`
    svg += `<rect width="${svgWidth}" height="${svgHeight}" fill="white"/>`

    for (let i = 0; i < bars.length; i++) {
      const w = bars[i] * moduleWidth
      if (i % 2 === 0) {
        // Bar (black)
        svg += `<rect x="${x}" y="0" width="${w}" height="${height}" fill="black"/>`
      }
      x += w
    }

    // Label text below barcode
    svg += `<text x="${svgWidth / 2}" y="${height + 15}" text-anchor="middle" font-family="monospace" font-size="14" fill="black">${this.escapeXml(label)}</text>`
    svg += `</svg>`

    return svg
  }

  downloadSvg() {
    const svg = this.barcodeOutputTarget.querySelector("svg")
    if (!svg) return

    const svgData = new XMLSerializer().serializeToString(svg)
    const blob = new Blob([svgData], { type: "image/svg+xml" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "barcode.svg"
    a.click()
    URL.revokeObjectURL(url)
    this.showStatus("SVG downloaded!", "success")
  }

  downloadPng() {
    const svg = this.barcodeOutputTarget.querySelector("svg")
    if (!svg) return

    const svgData = new XMLSerializer().serializeToString(svg)
    const canvas = document.createElement("canvas")
    const ctx = canvas.getContext("2d")
    const img = new Image()

    const svgBlob = new Blob([svgData], { type: "image/svg+xml;charset=utf-8" })
    const url = URL.createObjectURL(svgBlob)

    img.onload = () => {
      const scale = 3
      canvas.width = img.width * scale
      canvas.height = img.height * scale
      ctx.fillStyle = "white"
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.drawImage(img, 0, 0, canvas.width, canvas.height)

      canvas.toBlob((blob) => {
        const pngUrl = URL.createObjectURL(blob)
        const a = document.createElement("a")
        a.href = pngUrl
        a.download = "barcode.png"
        a.click()
        URL.revokeObjectURL(pngUrl)
        this.showStatus("PNG downloaded!", "success")
      }, "image/png")

      URL.revokeObjectURL(url)
    }

    img.src = url
  }

  escapeXml(text) {
    return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }

  showStatus(message, type = "") {
    if (!this.hasStatusMessageTarget) return
    this.statusMessageTarget.textContent = message
    this.statusMessageTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")

    if (type === "success") {
      this.statusMessageTarget.classList.add("text-green-600", "dark:text-green-400")
    } else if (type === "error") {
      this.statusMessageTarget.classList.add("text-red-500", "dark:text-red-400")
    }
  }
}
