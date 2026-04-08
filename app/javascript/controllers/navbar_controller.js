import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "categoryMenu", "categoriesButton", "menuButton"]

  connect() {
    this.handleClickOutside = this.clickOutside.bind(this)
    this.handleKeydown = this.keydown.bind(this)
    document.addEventListener("click", this.handleClickOutside)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
    document.removeEventListener("keydown", this.handleKeydown)
  }

  toggleMenu() {
    this.menuTarget.classList.toggle("hidden")
    const isOpen = !this.menuTarget.classList.contains("hidden")

    if (this.hasMenuButtonTarget) {
      this.menuButtonTarget.setAttribute("aria-expanded", isOpen.toString())
    }

    if (isOpen) {
      this.trapFocusInMenu()
    } else {
      this.releaseFocusTrap()
    }
  }

  toggleCategories(event) {
    event.stopPropagation()
    this.categoryMenuTarget.classList.toggle("hidden")
    const isOpen = !this.categoryMenuTarget.classList.contains("hidden")

    if (this.hasCategoriesButtonTarget) {
      this.categoriesButtonTarget.setAttribute("aria-expanded", isOpen.toString())
    }
  }

  clickOutside(event) {
    if (this.hasCategoryMenuTarget && !event.target.closest("[data-navbar-target='categoryDropdown']")) {
      this.categoryMenuTarget.classList.add("hidden")
      if (this.hasCategoriesButtonTarget) {
        this.categoriesButtonTarget.setAttribute("aria-expanded", "false")
      }
    }
  }

  keydown(event) {
    if (event.key === "Escape") {
      if (this.hasCategoryMenuTarget && !this.categoryMenuTarget.classList.contains("hidden")) {
        this.categoryMenuTarget.classList.add("hidden")
        if (this.hasCategoriesButtonTarget) {
          this.categoriesButtonTarget.setAttribute("aria-expanded", "false")
          this.categoriesButtonTarget.focus()
        }
      }

      if (this.hasMenuTarget && !this.menuTarget.classList.contains("hidden")) {
        this.menuTarget.classList.add("hidden")
        if (this.hasMenuButtonTarget) {
          this.menuButtonTarget.setAttribute("aria-expanded", "false")
          this.menuButtonTarget.focus()
        }
        this.releaseFocusTrap()
      }
    }
  }

  trapFocusInMenu() {
    const focusableSelectors = 'a[href], button, input, textarea, select, [tabindex]:not([tabindex="-1"])'
    const focusableElements = this.menuTarget.querySelectorAll(focusableSelectors)

    if (focusableElements.length === 0) return

    this.firstFocusable = focusableElements[0]
    this.lastFocusable = focusableElements[focusableElements.length - 1]

    this.handleTrapKeydown = (event) => {
      if (event.key !== "Tab") return

      if (event.shiftKey) {
        if (document.activeElement === this.firstFocusable) {
          event.preventDefault()
          this.lastFocusable.focus()
        }
      } else {
        if (document.activeElement === this.lastFocusable) {
          event.preventDefault()
          this.firstFocusable.focus()
        }
      }
    }

    this.menuTarget.addEventListener("keydown", this.handleTrapKeydown)
    this.firstFocusable.focus()
  }

  releaseFocusTrap() {
    if (this.handleTrapKeydown) {
      this.menuTarget.removeEventListener("keydown", this.handleTrapKeydown)
      this.handleTrapKeydown = null
    }
  }
}
