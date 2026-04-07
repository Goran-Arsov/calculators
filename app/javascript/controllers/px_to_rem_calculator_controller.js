import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "pxInput", "baseSize",
    "remResult", "emResult", "ptResult", "percentResult",
    "referenceTable"
  ]

  connect() {
    this.calculate()
    this.buildReferenceTable()
  }

  calculate() {
    var px = parseFloat(this.pxInputTarget.value)
    var base = parseFloat(this.baseSizeTarget.value) || 16

    if (isNaN(px) || base <= 0) {
      this.remResultTarget.textContent = "\u2014"
      this.emResultTarget.textContent = "\u2014"
      this.ptResultTarget.textContent = "\u2014"
      this.percentResultTarget.textContent = "\u2014"
      return
    }

    var rem = px / base
    var em = rem
    var pt = px * 0.75
    var percent = rem * 100

    this.remResultTarget.textContent = rem.toFixed(4) + "rem"
    this.emResultTarget.textContent = em.toFixed(4) + "em"
    this.ptResultTarget.textContent = pt.toFixed(2) + "pt"
    this.percentResultTarget.textContent = percent.toFixed(2) + "%"

    this.buildReferenceTable()
  }

  buildReferenceTable() {
    var base = parseFloat(this.baseSizeTarget.value) || 16
    if (base <= 0) return

    var sizes = [8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 36, 40, 48, 56, 64]
    var html = ""
    for (var i = 0; i < sizes.length; i++) {
      var px = sizes[i]
      var rem = (px / base).toFixed(4)
      html += '<tr class="border-b border-gray-100 dark:border-gray-700">'
      html += '<td class="py-2 px-3 text-sm font-mono text-gray-900 dark:text-white">' + px + 'px</td>'
      html += '<td class="py-2 px-3 text-sm font-mono text-gray-900 dark:text-white">' + rem + 'rem</td>'
      html += '<td class="py-2 px-3 text-sm font-mono text-gray-900 dark:text-white">' + (px * 0.75).toFixed(2) + 'pt</td>'
      html += '<td class="py-2 px-3"><button data-action="click->px-to-rem-calculator#copyValue" data-value="' + rem + 'rem" class="text-xs px-2 py-0.5 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 rounded-lg hover:bg-blue-200 dark:hover:bg-blue-900/50 transition-colors">Copy</button></td>'
      html += '</tr>'
    }
    this.referenceTableTarget.innerHTML = html
  }

  copyRem() {
    navigator.clipboard.writeText(this.remResultTarget.textContent)
  }

  copyEm() {
    navigator.clipboard.writeText(this.emResultTarget.textContent)
  }

  copyPt() {
    navigator.clipboard.writeText(this.ptResultTarget.textContent)
  }

  copyPercent() {
    navigator.clipboard.writeText(this.percentResultTarget.textContent)
  }

  copyValue(event) {
    var value = event.currentTarget.dataset.value
    navigator.clipboard.writeText(value)
    event.currentTarget.textContent = "Copied!"
    setTimeout(function() { event.currentTarget.textContent = "Copy" }, 1500)
  }
}
