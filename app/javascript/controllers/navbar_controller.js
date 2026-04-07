import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "categoryMenu"]

  connect() {
    this.handleClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
  }

  toggleMenu() {
    this.menuTarget.classList.toggle("hidden")
  }

  toggleCategories(event) {
    event.stopPropagation()
    this.categoryMenuTarget.classList.toggle("hidden")
  }

  clickOutside(event) {
    if (this.hasCategoryMenuTarget && !event.target.closest("[data-navbar-target='categoryDropdown']")) {
      this.categoryMenuTarget.classList.add("hidden")
    }
  }
}
