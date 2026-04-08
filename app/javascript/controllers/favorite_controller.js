import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { slug: String, name: String, path: String }

  connect() {
    this.updateAppearance()
  }

  toggle() {
    const favorites = this.#loadFavorites()
    const index = favorites.findIndex(f => f.slug === this.slugValue)

    if (index >= 0) {
      favorites.splice(index, 1)
    } else {
      favorites.unshift({ slug: this.slugValue, name: this.nameValue, path: this.pathValue })
    }

    localStorage.setItem("calcwise_favorites", JSON.stringify(favorites.slice(0, 20)))
    this.updateAppearance()
  }

  updateAppearance() {
    const isFav = this.#isFavorited()
    this.element.setAttribute("aria-pressed", isFav.toString())
    this.element.querySelector("[data-icon='filled']").classList.toggle("hidden", !isFav)
    this.element.querySelector("[data-icon='outline']").classList.toggle("hidden", isFav)
  }

  #isFavorited() {
    return this.#loadFavorites().some(f => f.slug === this.slugValue)
  }

  #loadFavorites() {
    try {
      return JSON.parse(localStorage.getItem("calcwise_favorites") || "[]")
    } catch {
      return []
    }
  }
}
