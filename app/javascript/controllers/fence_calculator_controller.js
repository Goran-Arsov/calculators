import { Controller } from "@hotwired/stimulus"
import { FT_TO_M } from "utils/units"

export default class extends Controller {
  static targets = ["length", "height", "spacing",
                    "unitSystem", "lengthLabel", "heightLabel", "spacingLabel",
                    "resultPosts", "resultRails", "resultPickets", "resultSections"]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(2)
    }
    convert(this.lengthTarget, FT_TO_M)
    convert(this.heightTarget, FT_TO_M)
    convert(this.spacingTarget, FT_TO_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Total Fence Length (m)" : "Total Fence Length (ft)"
    this.heightLabelTarget.textContent = metric ? "Fence Height (m)" : "Fence Height (ft)"
    this.spacingLabelTarget.textContent = metric ? "Post Spacing (m)" : "Post Spacing (ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const heightInput = parseFloat(this.heightTarget.value) || (metric ? 6 * FT_TO_M : 6)
    const spacingInput = parseFloat(this.spacingTarget.value) || (metric ? 8 * FT_TO_M : 8)

    // Imperial math internally.
    const length = metric ? lengthInput / FT_TO_M : lengthInput
    const height = metric ? heightInput / FT_TO_M : heightInput
    const spacing = metric ? spacingInput / FT_TO_M : spacingInput

    const posts = length > 0 ? Math.ceil(length / spacing) + 1 : 0
    const sections = Math.max(posts - 1, 0)
    const railsPerSection = height >= 5 ? 3 : 2
    const rails = sections * railsPerSection
    const picketWidth = 3.5 / 12
    const picketsPerSection = spacing > 0 ? Math.ceil(spacing / picketWidth) : 0
    const pickets = picketsPerSection * sections

    this.resultPostsTarget.textContent = this.fmt(posts)
    this.resultRailsTarget.textContent = this.fmt(rails)
    this.resultPicketsTarget.textContent = this.fmt(pickets)
    this.resultSectionsTarget.textContent = this.fmt(sections)
  }

  copy() {
    const posts = this.resultPostsTarget.textContent
    const rails = this.resultRailsTarget.textContent
    const pickets = this.resultPicketsTarget.textContent
    const sections = this.resultSectionsTarget.textContent
    const text = `Fence Estimate:\nPosts: ${posts}\nRails: ${rails}\nPickets: ${pickets}\nSections: ${sections}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 0, maximumFractionDigits: 0 })
  }
}
