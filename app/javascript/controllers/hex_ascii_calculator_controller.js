import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "outputHexSpaced", "outputHexCompact", "outputHexPrefixed",
    "outputBinary", "outputDecimal",
    "resultCharCount", "resultByteCount"
  ]

  textToHex() {
    const text = this.inputTarget.value
    if (!text) { this.clearResults(); return }

    const bytes = new TextEncoder().encode(text)
    this.outputHexSpacedTarget.value = Array.from(bytes).map(b => b.toString(16).toUpperCase().padStart(2, "0")).join(" ")
    this.outputHexCompactTarget.value = Array.from(bytes).map(b => b.toString(16).padStart(2, "0")).join("")
    this.outputHexPrefixedTarget.value = Array.from(bytes).map(b => "0x" + b.toString(16).toUpperCase().padStart(2, "0")).join(" ")
    this.outputBinaryTarget.value = Array.from(bytes).map(b => b.toString(2).padStart(8, "0")).join(" ")
    this.outputDecimalTarget.value = Array.from(bytes).map(b => b.toString()).join(" ")
    this.resultCharCountTarget.textContent = text.length.toLocaleString()
    this.resultByteCountTarget.textContent = bytes.length.toLocaleString()
  }

  hexToText() {
    const input = this.inputTarget.value.trim()
    if (!input) { this.clearResults(); return }

    try {
      const clean = input.replace(/0x/gi, "").replace(/[,\s]+/g, " ").trim()
      let hexPairs
      if (clean.includes(" ")) {
        hexPairs = clean.split(" ")
      } else {
        hexPairs = clean.match(/.{1,2}/g) || []
      }
      const bytes = new Uint8Array(hexPairs.map(h => parseInt(h, 16)))
      const decoded = new TextDecoder().decode(bytes)

      this.outputHexSpacedTarget.value = decoded
      this.outputHexCompactTarget.value = ""
      this.outputHexPrefixedTarget.value = ""
      this.outputBinaryTarget.value = Array.from(bytes).map(b => b.toString(2).padStart(8, "0")).join(" ")
      this.outputDecimalTarget.value = Array.from(bytes).map(b => b.toString()).join(" ")
      this.resultCharCountTarget.textContent = decoded.length.toLocaleString()
      this.resultByteCountTarget.textContent = bytes.length.toLocaleString()
    } catch (e) {
      this.outputHexSpacedTarget.value = "Error: Invalid hex input"
      this.clearStats()
    }
  }

  clearStats() {
    this.resultCharCountTarget.textContent = "\u2014"
    this.resultByteCountTarget.textContent = "\u2014"
  }

  clearResults() {
    this.outputHexSpacedTarget.value = ""
    this.outputHexCompactTarget.value = ""
    this.outputHexPrefixedTarget.value = ""
    this.outputBinaryTarget.value = ""
    this.outputDecimalTarget.value = ""
    this.clearStats()
  }

  copyHexSpaced() { navigator.clipboard.writeText(this.outputHexSpacedTarget.value) }
  copyHexCompact() { navigator.clipboard.writeText(this.outputHexCompactTarget.value) }
  copyBinary() { navigator.clipboard.writeText(this.outputBinaryTarget.value) }
  copyDecimal() { navigator.clipboard.writeText(this.outputDecimalTarget.value) }
}
