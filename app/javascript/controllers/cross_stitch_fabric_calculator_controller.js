import { Controller } from "@hotwired/stimulus"

const FABRIC_COUNTS = [
  { count: 11, type: "Aida 11" },
  { count: 14, type: "Aida 14" },
  { count: 16, type: "Aida 16" },
  { count: 18, type: "Aida 18" },
  { count: 20, type: "Aida 20" },
  { count: 22, type: "Aida 22 / Hardanger" },
  { count: 25, type: "Lugana 25" },
  { count: 28, type: "Evenweave 28" },
  { count: 32, type: "Evenweave 32" },
  { count: 36, type: "Evenweave 36" },
  { count: 40, type: "Linen 40" }
]

export default class extends Controller {
  static targets = [
    "designWidth", "designHeight", "count", "marginIn", "stitchesOver",
    "resultDesignIn", "resultDesignCm", "resultFabricIn", "resultFabricCm",
    "resultTotalStitches", "comparisonBody"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const designWidth = parseInt(this.designWidthTarget.value) || 0
    const designHeight = parseInt(this.designHeightTarget.value) || 0
    const count = parseInt(this.countTarget.value) || 0
    const marginIn = parseFloat(this.marginInTarget.value)
    const margin = isNaN(marginIn) ? 0 : marginIn
    const stitchesOver = parseInt(this.stitchesOverTarget.value) || 1

    if (designWidth <= 0 || designHeight <= 0 || count <= 0 || margin < 0 || stitchesOver <= 0) {
      this.clearResults()
      return
    }

    const effectiveCount = count / stitchesOver
    const designWidthIn = designWidth / effectiveCount
    const designHeightIn = designHeight / effectiveCount
    const fabricWidthIn = designWidthIn + (2 * margin)
    const fabricHeightIn = designHeightIn + (2 * margin)

    const designWidthCm = designWidthIn * 2.54
    const designHeightCm = designHeightIn * 2.54
    const fabricWidthCm = fabricWidthIn * 2.54
    const fabricHeightCm = fabricHeightIn * 2.54

    const totalStitches = designWidth * designHeight

    this.resultDesignInTarget.textContent = `${designWidthIn.toFixed(2)} × ${designHeightIn.toFixed(2)} in`
    this.resultDesignCmTarget.textContent = `${designWidthCm.toFixed(2)} × ${designHeightCm.toFixed(2)} cm`
    this.resultFabricInTarget.textContent = `${fabricWidthIn.toFixed(2)} × ${fabricHeightIn.toFixed(2)} in`
    this.resultFabricCmTarget.textContent = `${fabricWidthCm.toFixed(2)} × ${fabricHeightCm.toFixed(2)} cm`
    this.resultTotalStitchesTarget.textContent = totalStitches.toLocaleString("en-US")

    this.renderComparison(designWidth, designHeight, stitchesOver, margin)
  }

  renderComparison(designWidth, designHeight, stitchesOver, margin) {
    if (!this.hasComparisonBodyTarget) return

    const rows = FABRIC_COUNTS.map((entry) => {
      const eff = entry.count / stitchesOver
      const fw = (designWidth / eff) + (2 * margin)
      const fh = (designHeight / eff) + (2 * margin)
      return `<tr class="border-b border-gray-200 dark:border-gray-800"><td class="py-2 pr-4 text-gray-700 dark:text-gray-300">${entry.type}</td><td class="py-2 pr-4 text-right text-gray-900 dark:text-white font-medium">${fw.toFixed(2)} × ${fh.toFixed(2)} in</td><td class="py-2 text-right text-gray-600 dark:text-gray-400">${(fw * 2.54).toFixed(2)} × ${(fh * 2.54).toFixed(2)} cm</td></tr>`
    }).join("")

    this.comparisonBodyTarget.innerHTML = rows
  }

  clearResults() {
    this.resultDesignInTarget.textContent = "0 × 0 in"
    this.resultDesignCmTarget.textContent = "0 × 0 cm"
    this.resultFabricInTarget.textContent = "0 × 0 in"
    this.resultFabricCmTarget.textContent = "0 × 0 cm"
    this.resultTotalStitchesTarget.textContent = "0"
    if (this.hasComparisonBodyTarget) this.comparisonBodyTarget.innerHTML = ""
  }

  copy() {
    const text = `Cross Stitch Fabric Results:\nDesign Size: ${this.resultDesignInTarget.textContent} (${this.resultDesignCmTarget.textContent})\nFabric to Buy: ${this.resultFabricInTarget.textContent} (${this.resultFabricCmTarget.textContent})\nTotal Stitches: ${this.resultTotalStitchesTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
