import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["length", "height", "spacing", "resultPosts", "resultRails", "resultPickets", "resultSections"]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 6
    const spacing = parseFloat(this.spacingTarget.value) || 8

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
