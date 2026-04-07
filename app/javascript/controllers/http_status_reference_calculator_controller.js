import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "statusCard", "resultCount"]

  connect() {
    this.updateCount()
  }

  filter() {
    const query = this.searchTarget.value.toLowerCase().trim()
    let visible = 0

    this.statusCardTargets.forEach(card => {
      const code = card.dataset.code || ""
      const name = card.dataset.name || ""
      const description = card.dataset.description || ""
      const matches = !query ||
        code.includes(query) ||
        name.toLowerCase().includes(query) ||
        description.toLowerCase().includes(query)

      card.style.display = matches ? "" : "none"
      if (matches) visible++
    })

    this.resultCountTarget.textContent = `${visible} status code${visible !== 1 ? "s" : ""}`
  }

  updateCount() {
    const total = this.statusCardTargets.length
    this.resultCountTarget.textContent = `${total} status codes`
  }

  clear() {
    this.searchTarget.value = ""
    this.filter()
  }
}
