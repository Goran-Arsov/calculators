import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["length", "height", "spacing", "resultPosts", "resultRails", "resultPickets", "resultSections"]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 6
    const spacing = parseFloat(this.spacingTarget.value) || 8

    const posts = Math.ceil(length / spacing) + 1
    const sections = posts - 1
    const railsPerSection = height > 6 ? 3 : 2
    const rails = sections * railsPerSection
    const pickets = Math.ceil(length / 0.5)

    this.resultPostsTarget.textContent = this.fmt(posts)
    this.resultRailsTarget.textContent = this.fmt(rails)
    this.resultPicketsTarget.textContent = this.fmt(pickets)
    this.resultSectionsTarget.textContent = this.fmt(sections)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 0, maximumFractionDigits: 0 })
  }
}
